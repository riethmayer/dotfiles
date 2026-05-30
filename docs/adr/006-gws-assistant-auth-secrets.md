# ADR-006: gws personal-assistant auth & secrets architecture

**Date:** 2026-05-30
**Status:** Accepted

## Context

A long-lived personal-assistant agent needs Google Workspace access (Gmail,
Calendar, Drive, Sheets, Docs, Tasks, People, Meet, Pub/Sub) to manage email,
admin, and apps. The `gws` CLI (googleworkspace/cli) is the access layer, backing
the `gws-*` skills. Installation is reproducible via `mise run gws` (bootstrap
script `*_gws.sh`), but **auth is per-machine runtime state** that must not live
in the dotfiles repo, and the credentials must follow the repo's secret rule:
real secrets live in Keychain / Secret Manager, never on disk in the repo.

## Decision

- **Dedicated GCP project `loose-497921`** hosts everything: the 9 enabled
  Workspace APIs, the OAuth client, and the secrets. Keeps the assistant's blast
  radius isolated from other projects.
- **OAuth *user* credentials** as `jan@riethmayer.de` (not a service account).
  The assistant runs on Jan's laptops, so the refresh token is protected by the
  **macOS Keychain** (`gws` stores it encrypted; `~/.config/gws/` is never stowed).
  Full-access scopes incl. `cloud-platform` (GCP work is in scope).
- **Secret Manager backup** in `loose-497921` so a new machine bootstraps without
  the console: `gws-oauth-client` (the Desktop `client_secret.json`) and
  `gws-refresh-token` (`gws auth export --unmasked`, the gcloud ADC
  authorized-user format).
- **Least-privilege access**: a dedicated **keyless** service account
  `gws-assistant@loose-497921.iam.gserviceaccount.com` holds
  `roles/secretmanager.secretAccessor` **only on those two secret resources**
  (resource-level binding, not project-wide). No JSON key is issued — when the
  assistant goes headless it should use impersonation / workload identity, not a
  downloaded key.

## Consequences

- New-machine setup: pull `gws-oauth-client` → `~/.config/gws/client_secret.json`,
  then `gws auth login` (or reseed from `gws-refresh-token`). Verify with
  `gws gmail users getProfile --params '{"userId":"me"}'`.
- **Gotcha:** `gws auth export` masks secret values to an 11-char placeholder by
  default — you MUST pass `--unmasked`, and run it in an **interactive** shell so
  the Keychain decrypt is available (a non-interactive tool shell stores garbage).
- The `gws-refresh-token` secret grants full Workspace + `cloud-platform` access —
  it is the most sensitive artifact. Project owners can read it (fine for solo
  use); the `gws-assistant` SA is the path for any future non-owner/headless runner.
- Deferred: issuing the SA a usable identity for headless runs (impersonation or
  workload-identity binding) — set up when the assistant first runs off-laptop.
- Runtime credentials (`~/.config/gws/*`, the Keychain entry) are deliberately
  outside the dotfiles repo, consistent with the secret-handling rule in AGENTS.md.
