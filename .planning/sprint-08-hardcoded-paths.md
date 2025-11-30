# Sprint 8: Hardcoded Paths

## Problem

1. `tmux.conf`: `/Users/janriethmayer/dotfiles` hardcoded in sessionx config
2. `010_llvm.zsh`: `/opt/homebrew/opt/llvm/` (Intel Mac incompatible)

## Tasks

### 8.1 Fix tmux sessionx path
Location: `stow/tmux/.config/tmux/tmux.conf`

Replace hardcoded path with:
- `$HOME/dotfiles` or
- `$XDG_CONFIG_HOME` based path or
- Remove if not needed

### 8.2 Fix LLVM path for portability
Location: `stow/zsh/.oh-my-zsh/custom/zshrc.d/010_llvm.zsh`
(or `.config/zsh/` equivalent after Sprint 1)

Current:
```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
```

Should detect architecture:
```bash
if [[ -d "/opt/homebrew/opt/llvm" ]]; then
  # Apple Silicon
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
elif [[ -d "/usr/local/opt/llvm" ]]; then
  # Intel Mac
  export PATH="/usr/local/opt/llvm/bin:$PATH"
fi
```

Or use `$(brew --prefix llvm)` if brew available.

### 8.3 Audit for other hardcoded paths
Search for `/Users/janriethmayer` and `/opt/homebrew` in all configs.

### 8.4 Test on current machine
Verify paths resolve correctly.

## Files Affected

```
stow/tmux/.config/tmux/tmux.conf
stow/zsh/.config/zsh/0XX_llvm.zsh (after Sprint 1)
```

## Acceptance Criteria

- [ ] No username in paths
- [ ] Homebrew paths portable to Intel/ARM
- [ ] Configs work on fresh machine
