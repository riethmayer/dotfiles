# AGENTS.md

Guidance for AI agents (Claude Code, OpenCode, Codex, …) working in this repository. `CLAUDE.md` is a symlink to this file.

## Repository Overview

Personal dotfiles managed with GNU Stow. Strict XDG Base Directory Specification compliance. Modular, per-tool organization.

## Key Commands

### Installation and Setup
- `mise run help` - Display all available tasks and stow packages
- `mise run install` - Install all stow packages (create symlinks)
- `mise run install-adopt` - Install with adoption of existing files (use for initial setup)
- `mise run bootstrap` - Complete system bootstrap (runs both stages)
- `mise run bootstrap-stage1` - Stage 1: Install Homebrew and Stow
- `mise run quick-bootstrap` - Quick bootstrap for development setup (essential tools only)
- `mise run delete` - Remove all stow symlinks
- `mise run update` - Sync dotfiles repo and handle git conflicts

### Tool-specific Setup
- `mise run tmux` - Setup tmux configuration
- `mise run gpg` - Setup GPG configuration
- `mise run nvim` - Setup Neovim configuration
- `mise run atuin` - Setup Atuin shell history
- `mise run zsh-xdg` - Setup Zsh XDG directories
- `mise run gws` - Install the Google Workspace CLI (gws) for the gws-* skills
- `mise run obsidian-today` - Install launchd agent: daily Desktop alias to today's Obsidian journal folder
- `mise run herdr` - Stow herdr config + install/refresh agent integrations (see ADR-008)

## Architecture and Structure

### Stow Organization
- Each tool/language has its own stow directory: `stow/{tool}/`
- Configuration files follow XDG Base Directory Specification
- Structure: `stow/tool/.config/tool/`, `stow/tool/.local/share/tool/`, etc.
- All packages listed in `PACKAGES` variable (derived from `stow/` subdirectories)

### Bootstrap System
- Two-stage bootstrap process via `mise run bootstrap`
- Stage 1: Install Homebrew and Stow (`stow/bootstrap/bin/system-bootstrap.sh`)
- Stage 2: Install all requirements (`$HOME/bin/system-bootstrap.sh`)
- Individual setup scripts in `stow/bootstrap/.system-bootstrap.d/`
- Scripts numbered with three digits for ordering, spaced in tens (`010_homebrew.sh`, `020_mise.sh`, …) so new steps slot between without renaming. Keep three digits — the sequence runs past 100, and a two-digit `20` would sort before `130`.
- All tasks managed through mise configuration in `stow/mise/.config/mise/config.toml`

### Configuration Loading
**Zsh Configuration:**
- Main config: `stow/zsh/.zshrc`
- Modular configs: `stow/zsh/.config/zsh/*.zsh`
- Loading pattern with numbered prefixes (000-099):
  - 000-009: Core environment
  - 010-029: Package managers
  - 030-049: Cloud tools
  - 050-069: Programming languages
  - 070-089: Development tools
  - 090-099: Shell enhancements
  - `99_local.zsh`: untracked per-machine overrides, sourced last (see below)

### Multi-Machine Setup — Local Overrides

This single repo is checked out identically on multiple machines (e.g. a work
laptop and a private one). Everything tracked is **shared and identical**;
anything that differs per machine — identity, work-only tooling, secrets —
lives in **gitignored `*.local` files** that each machine fills in for itself.
The local file *is* the machine's identity; no `hostname` detection is needed.

Three tiers:
- **Tracked (shared):** all tool configs, aliases, keymaps, structure, and
  declarative intent (e.g. `enabledPlugins` in `settings.json`).
- **Gitignored local (the seam, plaintext, per-machine):** the `*.local` files.
- **Never on disk in the repo (secrets):** keep in macOS Keychain / 1Password /
  GCP Secret Manager. Local files *reference* them, never store them.

Seams currently wired:

| Tool | Tracked | Untracked local (gitignored) | How it loads |
|------|---------|------------------------------|--------------|
| git  | `stow/git/.config/git/config` (ends in `[include] path = ~/.config/git/local`) | `stow/git/.config/git/local` | git reads the include last, so local overrides everything. Holds `[user]`, `coderabbit.machineId`, and absolute-path `allowedSignersFile`. |
| zsh  | `stow/zsh/.config/zsh/*.zsh` | `stow/zsh/.config/zsh/99_local.zsh` | `~/.config/zsh` is a stow symlink into the repo dir, so the `*.zsh` glob in `.zshrc` sources `99_local.zsh` last automatically (the `.example` is skipped — glob requires `.zsh`). |
| Claude | `stow/claude/.claude/settings.json` (shared intent) | `~/.claude/settings.local.json` + plugin runtime (`installed_plugins.json`, `known_marketplaces.json`, `cache/`) | runtime plugin state is gitignored — it carries absolute install paths that break across machines (different `$HOME`), so it must never be committed. |
| pi   | `stow/pi/.pi/agent/settings.json.example` (shared defaults) | `stow/pi/.pi/agent/settings.json` | pi rewrites its own settings.json with runtime state (`lastChangelogVersion`) on every update, so the real file is gitignored; `155_pi.sh` seeds it from the example. |

Each seam ships a tracked `*.example` template showing what to put in it.
**Setup on a new machine:** `cp <file>.example <file>` next to it, edit in this
machine's values, then `mise run install` (git needs the restow to link
`~/.config/git/local`; zsh picks it up with no install step).

**Rules of thumb when editing tracked config:**
- Never commit an absolute home path (`/Users/<name>/…`) — a different macOS
  username breaks it. Use `~`/`$HOME`, or move it to the `*.local` file.
- Never commit identity, machine ids, tokens, or anything work-specific.
- Adding a new per-machine knob? Extend the right `*.local` file + its
  `*.example`, and add the real file to `.gitignore`.

### XDG Compliance Rules
All configurations must follow XDG Base Directory Specification:
- Configurations → `$XDG_CONFIG_HOME` (~/.config)
- Data files → `$XDG_DATA_HOME` (~/.local/share)
- State files → `$XDG_STATE_HOME` (~/.local/state)
- Cache files → `$XDG_CACHE_HOME` (~/.cache)

### Key Packages
Current stow packages: agents, atuin, bootstrap, brew, claude, ghostty, git, herdr, mise, nvim, opencode, pi, pnpm, ruby, scripts, ssh, starship, tmux, zsh

## Development Patterns

### Adding New Tools
1. Create `stow/{tool}/` directory following XDG structure
2. Add tool-specific bootstrap script: `stow/bootstrap/.system-bootstrap.d/XXX_{tool}.sh`
3. Add mise task for individual tool setup in `stow/mise/.config/mise/config.toml`
4. For Zsh integration: add `stow/zsh/.oh-my-zsh/custom/zshrc.d/XXX_{tool}.zsh`

### Adding Agent Skills

Personal skill content now lives outside dotfiles in `~/src/my-skills`
(`git@github.com:riethmayer/skills.git`). Dotfiles owns only setup and entry
points:

```
~/src/my-skills/skills/<name>/            real skill files (edit/commit there)
stow/agents/.agents/skills                →  ../../../../src/my-skills/skills
~/.agents/skills                          →  ../dotfiles/stow/agents/.agents/skills
Codex jan-skills marketplace              →  git@github.com:riethmayer/skills.git --ref main
Claude jan-skills plugins (enabled)       →  github:riethmayer/skills (.claude-plugin/marketplace.json)
```

Run `mise run skills` to clone/update the repo, register the Codex marketplace,
and install the background updater. `mise run install` prepares the external
checkout before stow so the single `~/.agents/skills` symlink is present by
default.

When adding or editing a skill, work in `~/src/my-skills`, not under
`stow/agents/.agents/skills`. If a tool writes a real directory into
`~/.agents/skills/<name>`, move that content into `~/src/my-skills/skills/<name>`
and rerun `mise run install`.

For in-progress local Codex marketplace testing before pushing the skills repo,
run with `MY_SKILLS_CODEX_MARKETPLACE_SOURCE=local`.

The same repo is also a **Claude plugin marketplace**: `scripts/sync-marketplace.mjs`
generates `.claude-plugin/marketplace.json` (root) + per-bundle
`plugins/<name>/.claude-plugin/plugin.json` alongside the Codex manifest, exposing
the grouped `jan-*` plugins. **Claude loads personal skills exclusively through
these plugins** — the `jan-*` bundles are enabled in tracked
`stow/claude/.claude/settings.json` (`extraKnownMarketplaces.jan-skills` → github
`riethmayer/skills`), and the former `~/.claude/skills` symlink is retired to
avoid double-loading. Per-machine live-editing of local skills goes through a
`jan-skills` directory-source override in `~/.claude/settings.local.json`.
`~/.agents/skills` stays stowed for Codex and other agents. Regenerate the
manifests after editing `skill-bundles.json` with `node scripts/sync-marketplace.mjs`
(or just the Claude artifacts with the `claude` subcommand).

### Script Organization
- System setup scripts: `stow/bootstrap/.system-bootstrap.d/`
- User scripts: `stow/scripts/bin/`
- Bootstrap entry point: `stow/bootstrap/bin/system-bootstrap.sh`

### Configuration Standards
- All scripts must be idempotent (safe to run multiple times)
- Use consistent error handling and logging
- Follow XDG paths in all configurations
- Keep configurations modular and tool-focused
- Document any non-XDG compliant tools
- Always use mise for automating tasks and as entry point

### Boyscout Rule — leave the repo 100% clean

**Before ending any session that touched dotfiles, `git status` must be empty.** No stray untracked files, no leftover modifications, no "I'll deal with it later".

For every leftover, pick exactly one:
1. **Commit it** — if it's a real dotfile change (config edit, new script, new stow package). Bundle it into the session's commit when topical, or make a separate `chore(scope):` commit when not.
2. **Gitignore it** — if it's tooling runtime output that will recur (MCP runtime dirs, plugin caches, build artifacts). Add the pattern to `.gitignore` with a one-line comment explaining what produces it.
3. **Delete it** — if it's a one-off artifact (a stray PNG, a debug log, a scratch file) that shouldn't recur. If it might recur, gitignore the pattern instead.

Never leave `?? something` or ` M something` behind for the next agent — the dotfiles repo is a high-traffic shared workspace, and every leftover poisons the next session's `git status` signal.

## Must-Read Context

Always read these before making changes:
- `docs/adr/` - Architecture decision records
