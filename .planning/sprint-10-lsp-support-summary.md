# Sprint 10: LSP Server Support - Summary

## Completed: 2025-11-30

## Changes Made
- Created `stow/bootstrap/.system-bootstrap.d/008_lsp_servers.sh`:
  - Installs LSP servers for common dotfiles filetypes
  - Uses Homebrew for: `lua-language-server`, `taplo`, `marksman`
  - Uses npm for: `bash-language-server`, `yaml-language-server`, `vscode-langservers-extracted`
  - Idempotent: checks for existing installs before installing
- Added `lsp` task to `.mise.toml`:
  - `mise run lsp` runs the LSP bootstrap script
- Updated `quick-bootstrap` task to include LSP setup:
  - Now runs `001_mise.sh`, `006_atuin.sh`, `007_zsh_xdg.sh`, `008_lsp_servers.sh`
- Updated `README.md`:
  - Documented `mise run quick-bootstrap` and `mise run lsp`
  - Clarified that LSPs cover bash, lua, yaml, toml, json, markdown

## Verification
- LSP bootstrap script is executable ✓
- `mise run lsp` wired to `008_lsp_servers.sh` ✓
- Quick bootstrap now includes LSP setup ✓
- README documents how to install LSP servers ✓

## Notes
- Neovim LSP configuration remains in separate repo (`riethmayer/nvim`)
- After running `mise run lsp`, configure these servers in Neovim LSP setup
- Script assumes Homebrew and npm are available (or installs Node via mise)