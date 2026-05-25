---
name: gcp-secrets-env-bootstrap
description: |
  Use when editing Secret Manager retrieval, `setup_env.sh`, or secret-backed
  environment bootstrap flows.
---

# GCP Secrets + Env Bootstrap

Use this skill to keep secret retrieval and env initialization consistent and safe.

## Repo Context

Common touchpoints include:

- `apps/eagleeye-web/setup_env.sh`
- `packages/prisma/setup_env.sh`
- Secret retrieval code under app server auth/common modules

## Workflow

1. Identify required runtime env vars and corresponding secret IDs.
2. Validate presence of required `*_SECRET_ID` variables.
3. Resolve secrets through existing Secret Manager patterns.
4. Set env values once and avoid repeated remote calls.
5. Preserve optional vs required secret semantics.

## Guardrails

- Never hardcode secret values in repo files.
- Keep secret resolution errors explicit and actionable.
- Avoid broad env mutation when only one module needs a value.
- Keep local bootstrap and runtime bootstrap behavior aligned.

## Trigger Checklist

Use this skill when tasks involve:

1. Secret-backed auth credential loading
2. setup scripts that generate or update `.env*` files
3. onboarding new env keys for app/package runtime
4. diagnosing Secret Manager boot failures
