---
name: call-dagger
description: >-
  Use when running Dagger CI/CD commands, building or deploying containers,
  debugging Cloud Build pipelines, or working with GCR authentication.
  Triggers on: "dagger call", "dagger build", "cloud build failed",
  "push to GCR", "publish image", "deploy to cloud run".
---

# Dagger CI/CD

TypeScript-based CI/CD module at `.cicd/`. Generic pipeline for all `@eagleeye/*` apps with per-app deploy functions.

## Module Structure

```
.cicd/
  src/
    index.ts              # @object() class — thin routing layer
    shared/
      config.ts           # Zod-validated PKG constants, PACKAGES map, helpers
      build.ts            # pruneInstallBuild(), buildNodeApp(), buildNextApp(), build()
      registry.ts         # publishContainer() — GCR with sha + latest tags
      cloud-run.ts        # updateServiceImage(), updateAndRunJob(), healthCheck(), etc.
      secrets.ts          # initGcpAuth(), fetchBuildEnv() (Secret Manager)
      simple-deploy.ts    # build → publish → updateService composition
    deploy/
      webhooks-server.ts  # → simpleDeploy()
      webhooks-token-rotator.ts
      slack-bot.ts
      mcp-server.ts       # migrate → deploy → health check
      time-to-meeting.ts  # build secrets → deploy → health check
      investment-thesis.ts # build secrets → no-traffic → seed Firestore → route
  package.json            # Standalone (NOT in pnpm workspace)
  tsconfig.json           # Decorator support
dagger.json               # Module config (repo root)
.daggerignore             # Mirrors .dockerignore
```

## API

All commands run from repo root, require `--src=.` and `--pkg`.
Supported apps are defined in `.cicd/src/shared/config.ts` (`PACKAGES` map).

```bash
# Build container image (local only, no push)
dagger call --progress=plain build --src=. --pkg=@eagleeye/mcp-server

# Verify image structure (dist/index.js, prisma checks, Next.js standalone, etc.)
dagger call --progress=plain verify --src=. --pkg=@eagleeye/mcp-server

# Export to local Docker as <name>:dev
dagger call --progress=plain export-to-docker --src=. --pkg=@eagleeye/mcp-server
```

### Publish / Deploy (require GCP credentials)

These need the `cloud-build-runner` SA key. One-time setup:
```bash
# Fetch key from Secret Manager (requires gcloud auth with project access)
export GCP_CREDENTIALS=$(gcloud secrets versions access latest \
  --secret=cloud-build-runner-json-key --project=ultra-acre-286807)
```

Then run from repo root:
```bash
# Publish to GCR (tags: eu.gcr.io/.../europe-west4/<name>:<sha> + :latest)
dagger call --progress=plain publish \
  --src=. --pkg=@eagleeye/mcp-server \
  --commit-sha=$(git rev-parse --short HEAD) \
  --gcp-credentials=env:GCP_CREDENTIALS

# Full deploy from any machine (build + push + app-specific deploy steps)
# No need to merge a PR — Dagger runs the same pipeline locally as in CI.
dagger call --progress=plain deploy \
  --src=. --pkg=@eagleeye/mcp-server \
  --commit-sha=$(git rev-parse --short HEAD) \
  --gcp-credentials=env:GCP_CREDENTIALS
```

The module accepts both base64-encoded and raw JSON keys.

## Running Commands

### MANDATORY execution rules

- **ALWAYS** use `--progress=plain` — Dagger has an interactive TUI that agents can't see
- **ALWAYS** redirect output to a file and run as background task — Dagger output can be very large and will collapse background task output buffers
- **ALWAYS** use `run_in_background: true` on the Bash tool — never use shell `&`
- **NEVER** chain dagger with other commands via `&&` or `;`
- After completion, use the `Read` tool on the log file to check results

```bash
# CORRECT — redirect to file, run in background, read file after
dagger call --progress=plain verify --src=. --pkg=@eagleeye/mcp-server > /tmp/dagger-verify.log 2>&1

# Then after task completes, use Read tool on /tmp/dagger-verify.log

# WRONG — no redirect (output too large for background task buffer)
dagger call --progress=plain verify --src=. --pkg=@eagleeye/mcp-server
```

Name log files descriptively: `/tmp/dagger-{command}-{app}.log` (e.g. `/tmp/dagger-build-mcp-server.log`).

### Secret Passing Rules

- `VAR=value dagger call ... --param=env:VAR` -- inline env for the dagger process
- Do NOT `export` separately then use `env:` -- Dagger reads env at its own process level
- For files: `--param=file:/path/to/file`
- For programmatic secrets inside functions: `dag.setSecret("name", value)`

## Prisma Auto-Detection

Apps with `prisma: true` in their `PACKAGES` config automatically get:
- Prisma generated client copied into the image
- Prisma schema + migrations copied for migrate-deploy jobs
- Verification checks for `@prisma/client` importability

No `--uses-prisma` flag needed — detected from config.

## GCR Authentication

Use `withRegistryAuth` API -- passes credentials directly to BuildKit. Never rely on host Docker config (`credHelpers` are unreliable across environments).

```typescript
image
  .withRegistryAuth("eu.gcr.io", "oauth2accesstoken", passwordSecret)
  .publish(tagged)
```

**Required IAM roles** for the pushing SA:
- `roles/storage.admin` -- GCS bucket access
- `roles/artifactregistry.writer` -- GCR now uses Artifact Registry backend

Without `artifactregistry.writer`, push fails with 403 at `/v2/token`.

## Cloud Build Integration

Cloud Build YAML should be a thin wrapper -- decode SA key, install Dagger CLI, call function.
Dagger version is extracted to `_DAGGER_VERSION` substitution for easy updates.

**Substitution rules in cloudbuild.yaml:**

| Context | Syntax | Example |
|---------|--------|---------|
| Cloud Build substitutions | `$VAR` | `$PROJECT_ID`, `$COMMIT_SHA` |
| User substitutions in `args` | `${_VAR}` | `${_DAGGER_VERSION}` |
| Shell env vars in `args` | `$$VAR` | `$$GCP_CREDENTIALS_B64` |
| Shell command substitution | `$$()` | `$$(cat file.json)` |
| `availableSecrets` section | `$VAR` | Always single `$` (not shell) |

SA key from Secret Manager is base64-encoded. Decode before passing to Dagger:
```yaml
GCP_CREDENTIALS=$$(echo "$$SECRET_B64" | base64 -d)
```

## Cloud Run Deploy Permissions

When updating Cloud Run services/jobs via API, the caller SA needs `iam.serviceaccounts.actAs` on the **target SA** (the identity the service/job runs as).

## SA Key Handling

Terraform stores SA keys as base64 in Secret Manager. Handle both formats:

```typescript
function decodeSaKey(raw: string): string {
  const trimmed = raw.trim()
  if (trimmed.startsWith("{")) return trimmed          // raw JSON
  return Buffer.from(trimmed, "base64").toString()     // base64
}
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `secret env var not found` | Env var not visible to dagger | Use inline `VAR=val dagger call` |
| 403 on GCR push | Missing `artifactregistry.writer` | Add AR role to SA |
| 403 with `credHelpers` | `gcloud auth configure-docker` | Use `withRegistryAuth` instead |
| `actAs` denied | Deployer can't assume target SA | Grant `serviceAccountUser` on target |
| `CONSUMER_INVALID` | `$$PROJECT_ID` in `availableSecrets` | Use single `$` (not shell context) |
| Build works locally, fails in CB | Dagger engine can't reach metadata server | Pass credentials explicitly, not ADC |
