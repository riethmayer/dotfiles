# ADR-011: Claude settings are rendered from a shared file plus a local overlay

**Date:** 2026-09-24
**Status:** Accepted. Supersedes [ADR-009](009-claude-settings-driver-seam.md).

## Context

Claude Code loads four settings scopes: user `~/.claude/settings.json`,
project `.claude/settings.json`, project-local `.claude/settings.local.json`,
and managed. There is no user-level `settings.local.json`.

Since ADR-009 and commits `5cae941` / `b1cac56` this repo assumed there was.
Work marketplaces (`earlybird-marketplace`), work plugin enables (`eb`, `ic`,
`shared`) and the driver choice (`model`, `fastMode`, `effortLevel`,
`modelSettings`) were moved into `~/.claude/settings.local.json`. Claude never
read that file. `claude plugin list --json` reported every plugin enabled only
there as `enabled: false`, and `/html-output` from `eb` 4.0.0 was installed
but never loaded. The tracked file kept working only because it still listed
the `jan-*` bundles itself.

ADR-009 also left a git clean filter on the tracked `settings.json`. The
filter kept driver keys out of commits but made `git status` report the file
dirty on every Claude write, and it was bypassed by anything that staged the
file without `git add`.

## Decision

Three files under `stow/claude/.claude/`:

| File | Tracked | Holds |
|------|---------|-------|
| `settings.shared.json` | yes | hooks, permissions, status line, env, shared marketplaces, `jan-*` enables |
| `settings.local.json` | no (gitignored) | work marketplaces, work plugin enables, driver choice, anything per machine |
| `settings.json` | no (gitignored) | the render; the only file Claude reads |

`stow/scripts/bin/claude-settings-render` produces `settings.json` as
`shared * local * driver-keys-of-current-settings.json` with `jq`. Objects
deep-merge, so `enabledPlugins` and `extraKnownMarketplaces` combine. Arrays
in the overlay replace the shared array whole. Driver keys Claude wrote into
the rendered file win, so a `/model` "save as default" survives a re-render.

Stow links `~/.claude/settings.json` to the rendered file, unchanged from
before, and `~/.claude/settings.local.json` to the overlay so
`dotfiles-local-sync` and hand edits keep one path. `110_claude.sh` renders
before stowing and adopts a stray real `~/.claude/settings.local.json` into
the seam. The clean filter, `.gitattributes` entry and
`claude-settings-clean` are removed; the bootstrap script unsets the per-clone
filter config.

## Consequences

- Work plugins load again. Nothing work-specific enters the tracked file.
- Edit `settings.shared.json` or `settings.local.json`, then run
  `claude-settings-render` (or `mise run install`). Editing the rendered
  `settings.json` by hand is lost on the next render, except for the four
  driver keys.
- Claude's runtime writes land in a gitignored file. `git status` stays clean
  after a `/model` switch with no filter involved.
- `settings.json.bak.*` files Claude or herdr write next to the live file are
  outside the repo and unaffected.
- A fresh machine: `dotfiles-local-sync pull` restores the overlay,
  `mise run install` renders and links. Until the overlay exists the render
  equals the shared file, which is the correct personal-machine state.
- The same rendering rule is the right shape for any tool that reads one
  file and has no include mechanism. pi and Claude Desktop keep their
  whole-file seams; they carry no shared intent worth tracking separately.
