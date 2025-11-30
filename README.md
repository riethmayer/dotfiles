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
| atuin | Shell history sync | ✅ |
| bootstrap | System setup scripts | N/A |
| brew | Homebrew bundle | N/A |
| claude | Claude AI assistant config | ✅ |
| ghostty | Ghostty terminal config | ✅ |
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
mise run update         # Sync and update dotfiles
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
