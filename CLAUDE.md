# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that uses GNU Stow for managing configuration files across development tools. The repository follows strict XDG Base Directory Specification compliance and uses a modular, tool-specific organization structure.

## Key Commands

### Installation and Setup
- `make help` - Display all available commands with descriptions
- `make install` - Install all stow packages (create symlinks)
- `make install-adopt` - Install with adoption of existing files (use for initial setup)
- `make bootstrap` - Complete system bootstrap (runs both stages)
- `make bootstrap_stage1` - Stage 1: Install Homebrew and Stow
- `make delete` - Remove all stow symlinks
- `make update` - Update repository sources

### Tool-specific Setup
- `make tmux` - Setup tmux configuration
- `make gpg` - Setup GPG configuration
- `make nvim` - Setup Neovim configuration
- `make atuin` - Setup Atuin shell history
- `make zsh-xdg` - Setup Zsh XDG directories

## Architecture and Structure

### Stow Organization
- Each tool/language has its own stow directory: `stow/{tool}/`
- Configuration files follow XDG Base Directory Specification
- Structure: `stow/tool/.config/tool/`, `stow/tool/.local/share/tool/`, etc.
- All packages listed in `PACKAGES` variable (derived from `stow/` subdirectories)

### Bootstrap System
- Two-stage bootstrap process via `make bootstrap`
- Stage 1: Install Homebrew and Stow (`stow/bootstrap/bin/system-bootstrap.sh`)
- Stage 2: Install all requirements (`$HOME/bin/system-bootstrap.sh`)
- Individual setup scripts in `stow/bootstrap/.system-bootstrap.d/`
- Scripts numbered with three digits for ordering (e.g., `001_mise.sh`)

### Configuration Loading
**Zsh Configuration:**
- Main config: `stow/zsh/.zshrc`
- Modular configs: `stow/zsh/.oh-my-zsh/custom/zshrc.d/*.zsh`
- Loading pattern with numbered prefixes (000-099):
  - 000-009: Core environment
  - 010-029: Package managers
  - 030-049: Cloud tools
  - 050-069: Programming languages
  - 070-089: Development tools
  - 090-099: Shell enhancements

### XDG Compliance Rules
All configurations must follow XDG Base Directory Specification:
- Configurations → `$XDG_CONFIG_HOME` (~/.config)
- Data files → `$XDG_DATA_HOME` (~/.local/share)
- State files → `$XDG_STATE_HOME` (~/.local/state)
- Cache files → `$XDG_CACHE_HOME` (~/.cache)

### Key Packages
Current stow packages: atuin, bootstrap, brew, git, mise, pnpm, ruby, scripts, ssh, starship, tmux, wezterm, windsurf, zsh

## Development Patterns

### Adding New Tools
1. Create `stow/{tool}/` directory following XDG structure
2. Add tool-specific bootstrap script: `stow/bootstrap/.system-bootstrap.d/XXX_{tool}.sh`
3. Add Makefile target for individual tool setup
4. For Zsh integration: add `stow/zsh/.oh-my-zsh/custom/zshrc.d/XXX_{tool}.zsh`

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