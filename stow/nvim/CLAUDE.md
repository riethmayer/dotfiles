# Neovim Configuration

LazyVim-based config managed via stow.

## Structure

```
.config/nvim/
├── init.lua              # Entry point, loads config.lazy
├── lazyvim.json          # Enabled extras
├── lua/
│   ├── config/
│   │   ├── lazy.lua      # Plugin manager setup
│   │   ├── options.lua   # Vim options (empty, uses LazyVim defaults)
│   │   ├── keymaps.lua   # Custom keymaps (empty, uses LazyVim defaults)
│   │   └── autocmds.lua  # Custom autocmds (empty)
│   └── plugins/
│       ├── extras.lua    # Theme (dracula), fzf-lua, yanky overrides
│       └── formatting.lua # conform.nvim config
```

## Enabled Extras

Languages: astro, docker, go, json, markdown, python, ruby, sql, tailwind, terraform, toml, typescript

Tools: claudecode, yanky, fzf, mini-hipatterns

## Custom Plugins

- **Theme**: dracula.nvim (overrides tokyonight)
- **Fuzzy finder**: fzf-lua with custom keymaps (`<leader>f` files, `<leader>g` grep)
- **Clipboard**: yanky.nvim with sqlite storage

## Formatting

Auto-format on save via conform.nvim:
- Python: ruff_format + ruff_organize_imports
- Markdown: prettierd/prettier
- Go: gofumpt + goimports

## Key Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - LSP/formatter/linter installer
- `:LazyExtras` - Enable/disable LazyVim extras

## Adding Plugins

Create new file in `lua/plugins/` returning plugin spec table. LazyVim auto-imports all files in this directory.

## Installation

```sh
cd ~/dotfiles && mise run install  # or: stow -t ~ nvim
```
