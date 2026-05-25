---
name: webhook-handler
description: |
  Use when adding a new webhook source to the webhooks-server. Covers handler
  code, tests, Terraform (Pub/Sub + optional secret), deploy, and provider
  configuration. Enforces the canonical one-server approach — never create
  standalone Cloud Functions or separate webhook endpoints.
  Triggers on: "add a webhook", "new webhook endpoint", "integrate X webhooks",
  "webhook for Stripe", "webhook handler", "webhook ingestion".
metadata:
  layer: composable-tool
  tags: [webhook, infrastructure, cloud-run, terraform]
---

# Webhook Handler

All webhooks go through `apps/webhooks-server/` — one Hono server on Cloud Run
with CloudEvents envelopes, Pub/Sub fan-out, and BigQuery ingestion into
`raw.webhook_events`.

## Guardrails

- **One server** — no standalone Cloud Functions, Python endpoints, or separate services
- **CloudEvents** — always use `createCloudEvent()`, never publish raw payloads
- **Topic naming** — `webhooks-{source}` matching the handler name
- **One BQ table** — all sources share `raw.webhook_events`, no per-source tables
- **Secrets** — never hardcode; use Secret Manager + Cloud Run `value_source`
- **Terraform first** — apply infra before deploying code so Pub/Sub topic exists

## Auth patterns

**Token auth** (default): global middleware validates `?token=` query param.
Read `handlers/affinity/routes.ts` as reference.

**HMAC auth** (GitHub, Stripe, etc.): skip global auth for the handler path
prefix in `core/auth.ts`, implement HMAC verification as handler middleware.
Read `handlers/github-actions/routes.ts` as reference. Key details:
- Clone request for body: `c.req.raw.clone().arrayBuffer()`
- Add secret env var to `core/env.ts` as optional field
- Use `timingSafeEqual` from `node:crypto`

## Workflow

1. **Read existing handlers** — `handlers/example/` (token), `handlers/github-actions/` (HMAC)
2. **Create handler** at `src/handlers/{source}/routes.ts` following the pattern
3. **Mount** in `src/app.ts`: `app.route("/{source}", handler)`
4. **Write tests** at `src/handlers/{source}/routes.test.ts` — mock env, secrets, pubsub (see `handlers/example/routes.test.ts`). Cover: auth failure (403), valid request (200 + CE envelope), publish failure (502)
5. **Verify** — `pnpm test && pnpm typecheck` in `apps/webhooks-server/`
6. **Terraform** — see [references/terraform.md](references/terraform.md) for module patterns. Add Pub/Sub in `pubsub.tf`, for HMAC add secret in `service_account.tf` and env var in `cloud_run.tf`
7. **Apply infra** — auto-execute `terragrunt plan` then `terragrunt apply` in `infra/gcp/eagleeye/apps/webhooks_server/`. If Cloud Run fails due to IAM race on new secrets, re-run plan+apply.
8. **Set secret** (HMAC only) — confirm with user before executing: generate secret, add version, force Cloud Run revision. See [references/terraform.md](references/terraform.md) for commands.
9. **Deploy code** — merge PR triggers `webhooks-server-cd` Cloud Build
10. **Configure provider** — share URL via `mise run webhooks:url {source}` (token) or `gh api` (HMAC)
11. **Verify e2e** — run `mise run webhooks:verify {source}` to check recent events in BigQuery

## Automation intent

| Action | Level | Rationale |
|---|---|---|
| Terragrunt plan/apply | Auto-execute | Safe infra creation, reviewable output |
| Set secret value | Confirm with user | Irreversible credential write |
| Force Cloud Run revision | Confirm with user | Production restart |
| Provider URL retrieval | Auto-execute | Read-only secret access |
| E2e verification queries | Auto-execute | Read-only BQ query |

## Gotchas

- **IAM race condition**: when adding a secret + Cloud Run env var in one apply, IAM may not propagate before Cloud Run mounts the secret. Re-run plan+apply if Cloud Run fails.
- **GitHub content_type**: must be `json`, not `application/json` — the latter silently sends form-encoded payloads.
- **Deploy ordering**: Terraform infra must exist before code deploys. Apply infra on the branch, merge triggers code deploy.

## Key files

| Purpose | Path |
|---|---|
| Route mounting | `apps/webhooks-server/src/app.ts` |
| Auth skip list | `apps/webhooks-server/src/core/auth.ts` |
| CloudEvents factory | `apps/webhooks-server/src/core/envelope.ts` |
| Env schema | `apps/webhooks-server/src/core/env.ts` |
| Token handler ref | `apps/webhooks-server/src/handlers/example/` |
| HMAC handler ref | `apps/webhooks-server/src/handlers/github-actions/` |
| Terraform | `infra/gcp/eagleeye/apps/webhooks_server/` |
| Pub/Sub module | `infra/gcp/_modules/pubsub_bq_ingestion/` |
| Secret module | `infra/gcp/_modules/secret/` |
| Operational tasks | `.agents/skills/webhook-handler/.mise.toml` (`webhooks:*`) |
