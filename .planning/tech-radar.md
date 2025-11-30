# Tech Radar

Tool adoption status. Not loaded into AI context by default.
Last updated: 2025-11-30

## Adopt
Active daily use, fully configured in stow.

**Shell & Terminal** ✅ Stowed
- zsh (XDG compliant), starship, atuin, zoxide, direnv
- ghostty, kitty, tmux (+ plugins: tpm, resurrect, continuum, sessionx, floax, catppuccin)
- fzf, fzf-git.sh

**Editors**
- nvim - Separate repo: [riethmayer/nvim](https://github.com/riethmayer/nvim)

**CLI Power Tools** ✅ In PATH
- gh (GitHub), lazygit, delta
- rg (ripgrep), fd, bat, jq
- tree

**AI Assistants** ✅ Stowed
- claude CLI - Anthropic assistant
- opencode - AI coding agent (upgraded from Trial)

**Version Management** ✅ Stowed
- mise (node, python, ruby, go, java, bun, pnpm)
- homebrew (Brewfile), stow

**Languages & Frameworks**
- TypeScript, Next.js, pnpm, turborepo - primary (work)
- Python - data/scripts (work)
- Go, Ruby - side projects (fun) ✅ Ruby gemrc stowed
- Java - legacy/occasional
- Lua - nvim/wezterm config

**Cloud & Infra**
- gcloud - ❌ Not stowed (contains credentials)
- terraform, docker

**Security** ✅ Configured
- ssh config ✅ Stowed (cannot use XDG, OpenSSH requirement)
- gnupg (cannot use XDG), 1password (SSH agent)

**Notes & Productivity** ✅ Scripts stowed
- obsidian (via scripts)
- Brag book system (shared Claude/OpenCode)

## Trial
Evaluating, partial config.

- LSP servers - Planning to add (Sprint 10):
  - bash-language-server, lua-language-server
  - yaml-language-server, taplo, marksman
  - vscode-langservers-extracted

## Assess
Exploring, not yet configured.

- terragrunt - terraform wrapper (have alias but not using much)

## Hold
Deprecated, rarely used, or replaced. Not in shell startup.

**Replaced**
- hub → gh
- ack, ag → rg
- find → fd
- cat → bat (but cat still used in scripts)
- oh-my-zsh → native zsh config (Sprint 1)

**Configured but not primary**
- wezterm → ghostty (but ✅ stowed as backup)
- windsurf (Codeium IDE) - ✅ stowed but not primary editor

**Removed from dotfiles**
- console-ninja - ❌ Removed (Sprint 8, VS Code specific)
- pack (Cloud Native Buildpacks) - not configured

**Never adopted**
- emacs - not using
- elixir, erlang - using golang instead
- fwup - Nerves/embedded Elixir (not doing IoT)

**Dependencies** (keep, required by other tools)
- spidermonkey - JS engine, likely CouchDB/Erlang dep
- wxmac/wxwidgets - GUI toolkit for Erlang observer/debugger
- cairo, pixman, glib, icu4c, libyaml, etc.

## Action Items

**To Add** (Sprint 10)
- [ ] Install LSP servers for better editor support
- [ ] Create bootstrap script for LSP setup

**To Remove**
- [x] console-ninja script - Removed (Sprint 8)
- [x] oh-my-zsh custom directory - Removed (Sprint 1)

**To Consider**
- [ ] Remove erlang/elixir dependencies if truly not needed
- [ ] Archive wezterm config if ghostty is stable
- [ ] Document windsurf usage or remove if not used
