# Tech Radar

Tool adoption status. Not loaded into AI context by default.

## Adopt
Active daily use, fully configured.

**Shell & Terminal**
- zsh, oh-my-zsh, starship, atuin, zoxide, direnv
- ghostty, tmux (+ plugins: tpm, resurrect, continuum, sessionx, floax, catppuccin)
- fzf, fzf-git.sh

**Editors**
- nvim (nightly), lazy.nvim

**CLI Power Tools**
- gh (GitHub), lazygit, delta
- rg (ripgrep), fd, bat, jq
- tree

**AI Assistants**
- claude CLI - Anthropic assistant

**Version Management**
- mise (node, python, ruby, go, java, bun, pnpm)
- homebrew, stow

**Languages & Frameworks**
- TypeScript, Next.js, pnpm, turborepo - primary (work)
- Python - data/scripts (work)
- Go, Ruby - side projects (fun)
- Java - legacy/occasional
- Lua - nvim config

**Cloud & Infra**
- gcloud, terraform, docker

**Security**
- gnupg, 1password (SSH agent)

**Notes & Productivity**
- obsidian (via scripts)

## Trial
Evaluating, partial config.

- opencode - AI coding agent

## Assess
Exploring, not yet configured.

- terragrunt - terraform wrapper (have alias but not using much)

## Hold
Deprecated, rarely used, or replaced. Not in shell startup.

**Replaced**
- hub → gh
- wezterm → ghostty
- ack, ag → rg
- find → fd
- cat → bat

**Not Using**
- windsurf (Codeium IDE)
- console-ninja
- pack (Cloud Native Buildpacks)
- emacs - not using
- elixir, erlang - using golang instead
- fwup - Nerves/embedded Elixir (not doing IoT)

**Dependencies** (keep, required by other tools)
- spidermonkey - JS engine, likely CouchDB/Erlang dep
- wxmac/wxwidgets - GUI toolkit for Erlang observer/debugger
- cairo, pixman, glib, icu4c, libyaml, etc.
