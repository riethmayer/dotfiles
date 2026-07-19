# dotfiles

Personal dotfiles using GNU Stow and XDG Base Directory Specification.

## Installation

Clone the dotfiles repository to your home directory:

```bash
git clone git@github.com:riethmayer/dotfiles $HOME/dotfiles
cd ~/dotfiles
mise run install
```

## Package Management

### Stow Packages

The following tools are managed via GNU Stow:

| Package | Description | XDG Compliant |
|---------|-------------|---------------|
| agents | Shared AI agent instructions and personal-skill symlinks | ✅ |
| atuin | Shell history sync | ✅ |
| bootstrap | System setup scripts | N/A |
| brew | Homebrew bundle | N/A |
| claude | Claude AI assistant config | ✅ |
| ghostty | Ghostty terminal config | ✅ |
| herdr | Herdr agent workspace manager (sidebar rows, keys, theme) | ✅ |
| git | Git configuration | ✅ |
| kitty | Kitty terminal config | ✅ |
| mise | Mise (rtx) config | ✅ |
| opencode | OpenCode AI config | ✅ |
| pnpm | PNPM configuration | ✅ |
| ruby | Ruby/Gem configuration | ✅ |
| scripts | Custom shell scripts | N/A |
| ssh | SSH configuration | ❌ (hardcoded) |
| starship | Starship prompt | ✅ |
| tmux | Tmux configuration | ✅ |

| zsh | Zsh configuration | ✅ |

### Separate Repositories

- **Neovim**: Configuration maintained at [riethmayer/nvim](https://github.com/riethmayer/nvim)
  - Clone to `~/.config/nvim`

### Excluded Tools

- **gcloud**: Google Cloud SDK config excluded (contains credentials)
- **gpg**: Cannot be stowed (hardcoded `~/.gnupg` path)

## Available Commands

```bash
mise run help           # Show available tasks
mise run install        # Install all stow packages
mise run bootstrap      # Full system setup
mise run quick-bootstrap # Minimal dev setup (mise, atuin, zsh-xdg, LSP)
mise run lsp            # Install LSP servers (bash, lua, yaml, toml, json, md)
mise run skills         # Install/update personal skills for Claude and Codex
mise run update         # Sync and update dotfiles
```

## Personal Skills

Personal agent skills live in `~/src/my-skills` and reach each agent through
its own marketplace install (Claude: `jan-*` plugins, Codex: `jan-skills`
marketplace) — content is duplicated per agent, no shared symlink. `mise run
install` prepares the checkout before stow; `mise run skills` registers the
Git-backed Codex `jan-skills` marketplace and a LaunchAgent that fast-forwards
the checkout hourly when it is clean.

## Cron

`cron/crontab.txt` is the source of truth for non-factory cron entries — install with `crontab ~/dotfiles/cron/crontab.txt`. Factory-owned entries self-install afterwards from their owning repo (marker-managed blocks, idempotent):

```bash
node ~/src/my-skills/scripts/reap-agents.mjs --install-cron   # herdr idle-agent reaper (15min)
```

## Directory Structure

```
dotfiles/
├── stow/              # GNU Stow packages
│   └── {tool}/        # Per-tool configurations
├── .planning/         # Sprint-based improvements
├── .rules/            # Shared rules for AI assistants
└── .mise.toml         # Task runner configuration
```

## Acknowledgments

Thanks to @andrzejsliwa and @sevos for the inspiration.
