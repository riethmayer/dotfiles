# AGENTS.md

Instructions for OpenCode when working in this repository.

## Resuming Work

When starting a session on this repo:
1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work

A sprint is complete when `sprint-{NN}-{name}-summary.md` exists. See `.rules/planning.md` for details.

## Repository Overview

Personal dotfiles using GNU Stow + XDG Base Directory Specification.

## Key Commands

- `mise run help` - List tasks and packages
- `mise run install` - Stow all packages
- `mise run bootstrap` - Full system setup

## Structure

- `stow/{tool}/` - Per-tool configs following XDG paths
- `stow/bootstrap/.system-bootstrap.d/` - Numbered setup scripts
- `.planning/` - Sprint-based improvement plans
- `.rules/` - Shared rules for AI assistants

## Patterns

- XDG paths: `.config/`, `.local/share/`, `.local/state/`, `.cache/`
- Idempotent scripts
- One stow package per tool

## Shared Rules

Load on need-to-know basis:
- `.rules/planning.md` - Sprint management (check when working on .planning/)
- `.rules/tools.md` - Tool preferences (rg, fd, gh, fzf, etc.)
- `.planning/tech-radar.md` - When adding/referencing technology, review and clarify categorization
