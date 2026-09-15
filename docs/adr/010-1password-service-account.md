# ADR-010: `op` runs as a per-machine service account

**Date:** 2026-09-15
**Status:** Accepted

## Context

Secrets on a laptop that must never be committed (repo `.env` files, the
seam files from AGENTS.md, CLI API keys) live in 1Password and reach disk
through `dotfiles-local-sync` and `op read`. Every one of those calls used
the interactive `op` session, which means a Touch ID prompt. That prompt
does not reach herdr agent panes, launchd jobs or Claude tool shells, so
the agents either hang or the secret is copied around by hand.

[1Password service accounts](https://www.1password.dev/service-accounts)
authenticate `op` with a token in `OP_SERVICE_ACCOUNT_TOKEN`, no session,
no biometrics. Constraints that shape the design:

- A service account cannot be granted the Private vault. Everything it
  needs must sit in a shared vault.
- Once the variable is set, `op` sees only that account's vaults.
- Families plan limits: 1,000 reads/hour per token, 1,000 calls/day for the
  whole 1Password account.

## Decision

- One shared vault `machines` holds every per-machine secret: the
  `dotfiles <machine> <slug>` documents, the `env-*` documents for repo
  `.env` files, and CLI items such as `ElevenLabs`.
- One service account per laptop, named after the host, scoped to
  `machines:read_items,write_items`.
- The token is stored in the login Keychain as `op-service-account-token`
  and exported by `076_1password.zsh` in every shell. It is never written
  to the repo or a dotfile.
- `dotfiles-local-sync` defaults to the `machines` vault; tracked `op://`
  references point at `machines`, never `Private`.
- `opme` (alias, token unset) is the escape hatch for a Private-vault
  lookup with Touch ID.
- `mise run 1password` verifies the setup and prints the one-time steps
  (vault, item moves, service-account create, Keychain add).

## Consequences

- Any `op` call from any shell or agent works unattended. Secrets are
  fetched, not pasted.
- No `op read` in shell startup: the daily budget is shared account-wide,
  and herdr opens many shells. Secrets materialise on demand (`pull`,
  `tts-speak`), which stays far below the limit.
- Losing the laptop means revoking that host's service account in the
  1Password admin console; the other machine's token is unaffected.
- The Keychain entry is readable by any process running as the logged-in
  user without a prompt. That is the accepted trade-off; the vault it
  unlocks holds machine secrets only, not the personal Private vault.
- The old `Private`-vault documents must be moved once (step 2 of
  `mise run 1password`); until then `dotfiles-local-sync` finds nothing.
