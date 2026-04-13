# ADR-005: Claude config split from agents to dedicated stow package

**Date:** 2026-04-12
**Status:** Accepted

## Context

`.claude/` config (settings.json, plugins, MCP config) was originally part of the `agents` stow package alongside `.agents/` skills. This caused stow conflicts when the two needed different lifecycle management — skills change frequently, Claude settings are stable.

## Decision

Move `.claude/` into its own `stow/claude/` package. The `agents` package manages `.agents/` (skills directory). `.claude/skills` is a symlink to `../../.agents/skills`, bridging the two packages.

## Consequences

- `stow/claude/` owns: settings.json, plugins/, .mcp.json, skills (symlink)
- `stow/agents/` owns: .agents/skills/* (actual skill files)
- Work-specific skills (e.g. earlybird-shared) should live in project repos, not dotfiles
- Adding a new skill = adding to `stow/agents/.agents/skills/`, automatically visible via symlink
