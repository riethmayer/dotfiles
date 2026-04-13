# ADR-004: Ghostty-to-tmux keybind forwarding via Alt sequences

**Date:** 2026-04-11
**Status:** Accepted

## Context

Ghostty intercepts Cmd+key before the shell/tmux sees it. Sending `\x01` (Ctrl-A prefix) directly from Ghostty doesn't reliably trigger tmux prefix mode due to `escape-time 0`.

## Decision

Use Alt (Meta) sequences as an intermediate layer:
- Ghostty maps `Cmd+key` → sends `\x1b{key}` (Alt+key)
- tmux binds `M-{key}` in root table (`bind-key -n`)

This is the same pattern used for `Cmd+{1-9}` window switching.

## Current mappings

| Ghostty        | Sends    | tmux binding | Action                |
|----------------|----------|--------------|-----------------------|
| Cmd+{1-9}      | Alt+{N}  | M-{N}        | Select window N       |
| Cmd+t          | Ctrl-A c | prefix+c     | New window            |
| Cmd+l          | Alt+l    | M-l          | sesh picker           |
| Cmd+o          | Alt+o    | M-o          | sesh last session     |
| Cmd+w          | Alt+w    | M-w          | Kill tmux window      |

## Consequences

- Alt+key sequences intercepted by tmux, unavailable for shell use (e.g. Alt+l = `ls` in oh-my-zsh won't work inside tmux — acceptable tradeoff)
- Only works inside tmux; on bare shell, Alt sequences pass through to zsh
- Keybinds source after TPM (`source-file` at end of tmux.conf) to prevent plugin overrides
