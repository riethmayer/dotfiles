---
name: ship
description: >-
  Autonomous PR merge and deploy. Runs /check-pr until green, squash-merges,
  monitors the Apps CD deploy, applies any Terragrunt infra the PR touched,
  and checks health + Sentry. Triggers on: "ship it", "ship this PR",
  "merge and deploy", "ship to production", "deploy this".
---

# Ship - Autonomous Merge & Deploy

Runs `/check-pr` -> squash-merge -> monitor the Apps CD deploy -> apply Terragrunt (if the PR touched infra) -> verify. Autonomous once invoked.

## Resolve PR

1. `$ARGUMENTS` contains PR number/URL -> extract it
2. No argument -> `gh pr view --json number -q .number`
3. No PR -> stop

## Step 1: Run /check-pr

Invoke `/check-pr` for the PR. This handles sync, CI fixes, review comments, CodeRabbit re-review, until green. If it exits with items needing human input, report and stop.

## Step 2: Squash Merge

Once `/check-pr` confirms all green:

```bash
gh pr merge $PR --squash --auto
```

`--auto` enables auto-merge, which is the right default: this monorepo enforces **strict branch protection** (the head branch must be up-to-date with master), so the merge fires once the branch is up-to-date and required checks pass. If the branch is `BEHIND`, sync first (`git fetch origin master && git merge origin/master --no-edit`, then `pnpm install` to relink any new workspace packages, then push) - auto-merge lands it after the re-run. Do NOT use `--admin` to bypass branch protection without explicit user say-so.

Capture the merge commit: `MERGE_SHA=$(gh pr view $PR --json mergeCommit -q .mergeCommit.oid)`.

## Step 3: Monitor the Apps CD deploy

EagleEye apps deploy via **GitHub Actions `apps-cd.yml` (Dagger)** on merge to master - NOT Cloud Build. Find and watch that run.

```bash
RUN=$(gh run list --workflow="Apps CD" --branch master --limit 10 \
  --json databaseId,headSha --jq "[.[] | select(.headSha==\"$MERGE_SHA\")][0].databaseId")

# Poll until the run is "completed"; each "Deploy @eagleeye/<app>" job = one Cloud Run service.
gh run view $RUN --json status,jobs \
  --jq '.status, (.jobs[] | select(.name|test("Deploy")) | "\(.status)/\(.conclusion // "-")  \(.name)")'
```

Poll (~45s) until `completed`. If no Apps CD run appears within ~2 min, the PR's files may not match the deploy path filter (`apps/`, `packages/`, `.cicd/`, ...) - report and skip to the ship report. If a `Deploy` job fails, report and stop (do not retry).

### 3b. Verify revisions + health (per deployed app)

Service names + domains are in the reference table at the bottom.

```bash
gcloud run services describe <service> --region=europe-west4 \
  --format='value(status.latestReadyRevisionName)'
curl -s -o /dev/null -w '%{http_code}\n' https://<domain>/api/health   # expect 200
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=<service> AND severity>=ERROR AND timestamp>=\"$(date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')\"" \
  --limit=20 --format='value(timestamp,severity,textPayload)'
```

### 3c. Sentry

Check for new errors after the merge timestamp via the Sentry MCP, scoped to the deployed app's project (e.g. `ee-pulse`, `ee-admin`). Report spikes; do not auto-rollback.

## Step 3.5: Apply Terragrunt (infra PRs only)

If the PR touched `infra/`, the code deploy alone does NOT apply infra. This step is what makes the env vars / secrets / IAM the new code depends on actually exist.

```bash
gh pr diff $PR --name-only | grep '^infra/gcp/eagleeye/apps/' || echo "no app-infra changes - skip 3.5"
```

If there are infra changes:

**Prereq - auth.** Needs gcloud + ADC. If `gcloud auth application-default print-access-token` fails, STOP and ask the user to run `gcloud auth login && gcloud auth application-default login` (they can type `! gcloud auth login` in-session). Terragrunt needs network + GCP creds; disable the Bash sandbox for terragrunt commands if one is active.

**Rule 1 - apply AFTER the deploy (Step 3 complete), never before.** A change that migrates an auth mechanism (e.g. shared-secret -> OIDC) removes env/secrets the OLD code still reads; applying before the new code is live breaks the live old service. The deploy is fail-closed friendly: apply promptly after it lands to close any gated-endpoint window.

**Identify the changed stacks:**

```bash
gh pr diff $PR --name-only | sed -n 's#^infra/gcp/eagleeye/apps/\([^/]*\)/.*#\1#p' | sort -u
```

**Rule 2 - re-plan FRESH (pre-deploy plans are stale).** The deploy bumps each app's Cloud Run state serial, so any plan saved before the deploy is rejected as stale on apply. Plan fresh, post-deploy, per stack:

```bash
cd infra/gcp/eagleeye/apps/<stack>
mise exec -- terragrunt plan -out=/tmp/<stack>.tfplan -input=false 2>&1 | grep -iE 'will be|Plan:|image|Error'
```

**Review each plan - two mandatory checks:**

1. **No image revert.** The Cloud Run change must be env/config only. If `image` appears in the Cloud Run resource diff, STOP - terragrunt should `ignore_changes` the image (Apps CD owns it); applying would roll back the just-deployed revision. Investigate before proceeding.
2. **Surface destroys.** Read the `Plan: A add, C change, D destroy` line. If `D > 0`, inspect exactly what is destroyed.

**Rule 3 - cross-stack destroy ordering.** If one stack DESTROYS a resource (e.g. a Secret Manager secret) that another changed stack references (e.g. an IAM binding to it), apply the **referencing stack first** (removes the binding while the resource still exists), THEN the **owning stack** (destroys the resource). Applying the owner first leaves the other apply to 404 on a dangling reference. If ordering is ambiguous, surface the plans and ask the human.

**Apply the reviewed fresh plan** (applies exactly what you reviewed, no prompt):

```bash
cd infra/gcp/eagleeye/apps/<stack>
mise exec -- terragrunt apply /tmp/<stack>.tfplan
```

Do NOT `terragrunt apply -auto-approve` a stack that has destroys - apply the reviewed saved plan. (`-auto-approve` is acceptable only for pure additive in-place env changes.)

**Re-verify after applying:** the affected service's health, and that the env the new code needs is live (e.g. a gated S2S endpoint returns 401 unauth, not 500). Note any positive path you cannot test from here (e.g. needing a service-account you cannot impersonate) for the user to confirm.

## Step 4: Ship Report

Post a ship-report comment on the PR (or update the body between `<!-- ship-report-start -->` / `<!-- ship-report-end -->` markers):

```markdown
## Ship Report

**Merged**: `<sha>` (squash)
**Deploy**: Apps CD run <id> SUCCESS - <service-revision(s)>
**Terragrunt**: <stacks applied, in order> (or "none - no infra changes")
**Health**: /api/health 200; gated endpoints 401 unauth; no errors in N min
**Review**: <findings addressed>
**Manual confirm pending**: <anything not testable from here>
```

## Guardrails

- **Infra after code, always** - never `terragrunt apply` before the Apps CD deploy completes.
- **Never `-auto-approve` a stack with destroys** - apply a reviewed fresh plan file.
- **Stop on missing gcloud/ADC auth** - ask the user to authenticate, don't guess.
- **No `--admin` merge** without explicit user say-so (don't bypass branch protection).
- **No force push.** Pull before push.
- **Global timeout** - ~45 min wall-clock; report and stop past it.
- **Deploy/apply failure** - report and stop, do not retry blindly.
- **Error spike post-deploy** - report, do not auto-rollback (human decision).

## Service / domain reference

| App path | Cloud Run service | Domain | Sentry project |
|---|---|---|---|
| `apps/pulse/` | `pulse` | `pulse.eagleeye.earlybird.com` | `ee-pulse` |
| `apps/mcp-server/` | `ee-mcp-server` | (S2S, no public domain) | `ee-mcp-server` |
| `apps/slack-bot/` | `slack-bot` | (event-driven, no public GET) | `ee-slack-bot` |
| `apps/admin/` | `admin` | `admin.eagleeye.earlybird.com` | `ee-admin` |
| `apps/scout/` | `scout` | `scout.eagleeye.earlybird.com` | `ee-scout` |
| `apps/time-to-meeting/` | `time-to-meeting` | `ttm.eagleeye.earlybird.com` | `ee-ttm` |
| `apps/eagleeye-web/` | N/A (Vercel) | `app.eagleeye.earlybird.com` | - |

Infra stacks live at `infra/gcp/eagleeye/apps/<stack>/` (note: underscores, e.g. `mcp_server`, `slack_bot`). If the PR touches no deployable app or infra, skip Steps 3-3.5 and just report the merge.
