# ADR-009: Claude driver choice is a seam, not a commit

**Date:** 2026-09-12
**Status:** Accepted

## Context

`~/.claude/settings.json` is a stow symlink into this repo, so the file Claude
Code writes to at runtime is a tracked file. Claude persists per-session state
there: `/model` writes `model` when you accept "save as default for new
sessions", and `fastMode`, `effortLevel` and `modelSettings` move with it.

Switching the driving model between Opus and Fable therefore produced an
uncommitted dotfiles change every time, and those changes reached commits —
noise that says nothing about how the machine is configured.

Three tiers exist in Claude Code: user (`~/.claude/settings.json`), project
(`.claude/settings.json`) and local (`.claude/settings.local.json`). They deep
merge, and local wins. `~/.claude/settings.local.json` was already in use here
for marketplaces and plugin enablement, and is already gitignored globally.

The pi package solves the same problem by making the whole settings file a seam:
the live file is gitignored and `settings.json.example` is tracked. That does not
transfer. Claude's settings carry 3.5 KB of hooks plus permissions and a status
line — the most valuable configuration in the repo, and the part most worth
versioning. Untracking all of it to hide a one-word model string is the wrong
trade.

## Decision

Split by volatility rather than by file.

Four keys — `model`, `fastMode`, `effortLevel`, `modelSettings` — are the
driver choice. Their real values live in `~/.claude/settings.local.json`, which
is gitignored and beats user settings on precedence. Everything else, hooks and
permissions included, stays tracked in `stow/claude/.claude/settings.json`.

Claude still writes its own copies of those four keys into the tracked file. A
git clean filter (`stow/scripts/bin/claude-settings-clean`, wired by
`110_claude.sh`) deletes them on the way into the index, so the working file
keeps whatever Claude wrote and the committed file never carries a driver
choice. The filter also sorts keys, so a rewrite that only reorders reads as no
change.

## Consequences

- Switching drivers produces nothing committable. `git diff --quiet` on the
  settings file returns 0 after a `/model` switch, and staging it stages
  nothing.
- `git status` still lists the file as modified until the next `git add`. Git
  does not refresh its stat cache for filtered paths, so it reports the file
  dirty on size and mtime alone while `git diff` runs the filter and finds no
  change. `git add .` clears the display and stages nothing. Cosmetic, and the
  price of keeping hooks tracked.
- The copies Claude writes into the tracked file are inert: the local file wins,
  so losing them to the filter costs nothing. This also defuses the usual clean
  filter hazard, where `git checkout` overwrites a working file with its
  stripped version.
- Hooks, permissions and the status line stay versioned and reviewable.
- The filter is per-clone git config and is not carried by the repo. A fresh
  machine gets it from `mise run install` via `110_claude.sh`; until that runs,
  the volatile keys would simply be committed as before.
- It fails open. Without `jq`, or against a file that is not valid JSON, the
  input passes through unchanged rather than being truncated.
- A new volatile key added by a future Claude release is not covered until it is
  named in the filter.
