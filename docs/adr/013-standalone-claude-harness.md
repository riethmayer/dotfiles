# ADR-013: Keep the Claude Code harness outside dotfiles

- **Status:** Accepted. Supersedes [ADR-005](005-claude-config-stow-split.md) and [ADR-011](011-claude-settings-render-seam.md).
- **Date:** 2026-10-11

## Context

The `stow/claude` package held Claude Code settings, hooks, the status line, output styles and the `websearch-perplexity` plugin. Because this repository is public, work-only hooks could not be tracked and travelled only through 1Password. The harness also changes in most working sessions, far more often than machine provisioning. ADR-012 moved the Pi harness out for the same reasons.

## Decision

The Claude Code harness lives in the private repository [`riethmayer/claude-harness`](https://github.com/riethmayer/claude-harness), checked out at `~/claude-harness`. Its `install.sh` renders settings and stows its `home/` package into `$HOME`. The settings render (ADR-011) continues there as claude-harness ADR-0002.

Dotfiles owns only:

- installing the `claude` binary, `~/.claude/CLAUDE.md`, Claude Desktop config and plugin runtime repair (`110_claude.sh`)
- cloning `claude-harness` and running its `install.sh` during bootstrap
- syncing the per-machine `settings.local.json` overlay through `dotfiles-local-sync`

## Consequences

- Harness changes no longer touch this repository.
- Work-only hooks are tracked in the private repository and no longer sync through 1Password.
- New machines need GitHub access to the private repository during bootstrap.
- The checkout is linked live, not pinned like the Pi harness. Edits take effect immediately.
