# ADR-002: sesh over tmux-sessionx

**Date:** 2026-04-11
**Status:** Accepted

## Context

tmux-sessionx was used for session management but is a tmux plugin (TPM-managed), adding plugin weight and limited flexibility. sesh is a standalone Go binary with zoxide integration, fzf-based picker, and session preview.

## Decision

Replace tmux-sessionx with sesh. Remove the plugin from TPM, add sesh keybindings via Ghostty (Cmd+l/o) forwarded as Alt sequences to tmux root-table bindings.

## Keybindings

- `Cmd+l` / `prefix+T` — sesh picker (fzf-tmux popup)
- `Cmd+o` / `prefix+L` — switch to last session
- `Cmd+w` — kill tmux window (with confirmation)

Ghostty sends Alt+{l,o,w}, tmux binds M-{l,o,w} in root table (no prefix needed).

## Consequences

- One fewer TPM plugin to maintain
- Picker works with zoxide, config dirs, and fd-based search
- Session preview in fzf popup
- Keybinds only work inside tmux (expected — sesh needs tmux)
- sesh.toml and zsh completions live in `stow/zsh/`
