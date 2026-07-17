# ADR-007: Personal skills live in a separate Git repo

**Date:** 2026-06-07
**Status:** Accepted (amended 2026-07-17)

## Context

Personal agent skills change more frequently than stable machine config. Keeping
all skill bodies in dotfiles made the dotfiles history noisy and forced every
skill edit through the stow repo. The skills are now maintained in
`git@github.com:riethmayer/skills.git`, checked out at `~/src/my-skills`.

## Decision

Dotfiles owns the installation and exposure points, not the skill content:

- `~/src/my-skills` is cloned and fast-forwarded by `personal-skills-sync`.
- `stow/agents/.agents/skills` is a committed symlink to
  `~/src/my-skills/skills`.
- `~/.agents/skills` is created by stow and is the shared raw-skill entry point.
- `~/.claude/skills` continues to point through `stow/claude/.claude/skills` to
  the shared `.agents` path.
- Codex registers `git@github.com:riethmayer/skills.git --ref main` as the
  Git-backed `jan-skills` marketplace while also seeing raw skills through
  `~/.agents/skills`.

`mise run install` prepares the external checkout before stow so old folded
`~/.agents/skills/<name>` links can be replaced by the single shared symlink.
`mise run skills`, full bootstrap, and a generated LaunchAgent keep the external
checkout updated. Dirty `~/src/my-skills` worktrees are fetched but never
fast-forwarded automatically. The same updater refreshes Codex's Git-backed
marketplace snapshot when it is registered.

## Consequences

- Dotfiles no longer commits personal skill bodies.
- Editing skills happens in `~/src/my-skills`.
- New machines need GitHub SSH access for `git@github.com:riethmayer/skills.git`.
- Claude uses the local checkout directly. Codex uses the pushed marketplace
  snapshot for plugin bundles and the local checkout for raw shared-skill
  discovery.
- ADR-005 still applies to the Claude config package split, but its statement
  that `stow/agents` owns actual skill files is superseded by this ADR.

## Amendment (2026-07-17): all skill symlinks retired

The shared raw-skill entry point is gone. `~/.agents/skills`,
`stow/agents/.agents/skills`, and `~/.claude/skills` are all retired;
`personal-skills-sync` removes them and its `--check` enforces their absence.
Every agent now consumes skills exclusively through its own marketplace
install — Claude via the `jan-*` plugins, Codex via the `jan-skills`
marketplace — accepting duplicated skill content per agent in exchange for
per-machine bundle selection: shared bundles are enabled in tracked
`stow/claude/.claude/settings.json`, work-only bundles only in the work
machine's gitignored `~/.claude/settings.local.json`. A raw symlink would
bypass that split by exposing every skill on every machine.
