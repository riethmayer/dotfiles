# ADR-008: Herdr replaces tmux as the terminal workspace manager

**Date:** 2026-07-16
**Status:** Accepted

## Context

tmux (+ sesh, sessionx, floax — ADR-002/003/004) served as the terminal
multiplexer. Herdr is a workspace manager built for AI coding agents: it
tracks per-pane agent state (via per-tool integration shims), surfaces it in
a sidebar, and routes agent notifications to the desktop. The Ghostty→tmux
Alt-forwarding trick (ADR-004) carries over unchanged.

## Decision

Adopt herdr as the daily driver; keep the tmux package tracked as fallback.

- `stow/herdr/` holds `config.toml` (keymaps mapped from the old tmux config,
  documented inline). Installed via mise (`herdr = "latest"`).
- Ghostty keybinds now target herdr: Cmd+T new space, Cmd+1..9 space N,
  Alt+1..9 tab N, Cmd+W close space (see `stow/ghostty/.config/ghostty/config`).
- `herdr integration install <tool>` writes version-stamped shims into tool
  config dirs. For stowed tools (claude, pi) the shims land in this repo and
  are **tracked**: they contain no machine paths, and committing them makes a
  fresh stow work before herdr is even installed. Rerun `mise run herdr`
  after `herdr update` and commit shim diffs.
- The claude installer appends a SessionStart hook entry to
  `~/.claude/settings.json` with an absolute home path; the tracked
  settings.json instead carries an equivalent guarded `$HOME` entry, and
  `160_herdr.sh` strips the absolute duplicate after every install.

## Consequences

- ADR-002 (sesh) and ADR-003 (tmux grid) are effectively superseded; the
  Ghostty sesh keybinds (Cmd+L/Cmd+O → Alt+l/Alt+o) still forward but only
  bind inside tmux, not herdr.
- Integration shim updates show up as tracked diffs — intentional, they are
  versioned config.
- `herdr integration status` is the health check for all shims.
