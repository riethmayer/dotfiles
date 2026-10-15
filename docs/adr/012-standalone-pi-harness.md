# ADR-012: Keep executable Pi harness code outside dotfiles

- **Status:** Accepted
- **Date:** 2026-10-10

## Context

The Pi customizations began as small files under `~/.pi/agent/extensions`. They grew into tested TypeScript modules with Effect runtime dependencies, a lockfile, an Effect-aware compiler, and their own release lifecycle. Keeping that implementation in dotfiles made machine provisioning own application code and coupled editor tooling to Stow layout.

## Decision

Reusable Pi extensions live in [`riethmayer/pi-harness`](https://github.com/riethmayer/pi-harness) as a versioned Pi package.

Dotfiles owns only:

- the pinned package declaration in Pi settings
- Pi version, keybindings, skills, and machine bootstrap
- installation reconciliation through `pi update --extensions`

Repository-specific Pi behavior remains in that repository's trusted `.pi/` directory. Herdr continues to own its generated Pi integration.

## Consequences

- Harness implementation, dependencies, tests, and releases change independently of machine configuration.
- Dotfiles upgrades the harness explicitly by changing a tag rather than following an unpinned checkout.
- New machines need GitHub access to the private harness repository during bootstrap.
- Local harness development uses `pi -e ~/pi-harness`; installed sessions use the pinned Git package.
