# ADR-003: tmux grid crash mitigations

**Date:** 2026-04-09
**Status:** Accepted

## Context

tmux 3.6a crashed with `SIGABRT` (`___BUG_IN_CLIENT_OF_LIBMALLOC_POINTER_BEING_FREED_WAS_NOT_ALLOCATED`) after 8 days of uptime. Stack trace: `grid_free_line` → `grid_clear_lines` → `screen_reinit` → `window_copy_clone_screen` — triggered when entering copy mode.

Root cause: memory corruption in grid data structures, exacerbated by concurrent `run-shell` forks from tmux-continuum saves and pane content capture interacting with grid memory.

## Decision

1. Disable `@resurrect-capture-pane-contents` — eliminates concurrent grid access from background forks
2. Reduce `@continuum-save-interval` from 15 to 60 minutes — fewer fork opportunities
3. Enable `monitor-bell` and add bell indicator to window status

## Consequences

- tmux-resurrect no longer captures pane scrollback on save (session layout still saved)
- Reduced save frequency means slightly more potential data loss on crash
- Known tmux bug — monitor upstream for a proper fix
