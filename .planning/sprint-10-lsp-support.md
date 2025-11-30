# Sprint 10: LSP Server Support

## Problem

Missing LSP servers for common file types in dotfiles:
- Shell scripts (.sh, .bash, .zsh)
- Configuration files (.toml, .yaml, .json)
- Documentation (.md)
- Lua configs (.lua)

## Tasks

### 10.1 Install LSP servers via Homebrew
```bash
brew install lua-language-server
brew install taplo
brew install marksman
```

### 10.2 Install LSP servers via npm
```bash
npm install -g bash-language-server
npm install -g yaml-language-server
npm install -g vscode-langservers-extracted
```

### 10.3 Create bootstrap script for LSP servers
Create `stow/bootstrap/.system-bootstrap.d/008_lsp_servers.sh`:
- Check for npm/node
- Install all LSP servers
- Make it idempotent

### 10.4 Document in nvim repo
Since nvim config is separate, document which LSP servers to configure.

### 10.5 Add to quick-bootstrap
Include LSP setup in development bootstrap.

## Files to Create

```
stow/bootstrap/.system-bootstrap.d/008_lsp_servers.sh
```

## Files to Update

```
.mise.toml (add lsp task)
README.md (document LSP setup)
```

## LSP Servers Needed

| Language/Format | LSP Server | Install Method | Files |
|-----------------|------------|----------------|-------|
| Shell scripts | bash-language-server | npm | *.sh, *.bash, *.zsh |
| Lua | lua-language-server | brew | wezterm.lua |
| YAML | yaml-language-server | npm | *.yml, *.yaml |
| TOML | taplo | brew | *.toml (mise, starship, atuin) |
| JSON | vscode-langservers-extracted | npm | *.json configs |
| Markdown | marksman | brew | *.md docs |

## Acceptance Criteria

- [ ] All LSP servers installed
- [ ] Bootstrap script created
- [ ] Installation is idempotent
- [ ] Works with nvim config
- [ ] Documented in README