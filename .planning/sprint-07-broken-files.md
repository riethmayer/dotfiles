# Sprint 7: Empty/Broken Files

## Problem

1. `000_path.zsh` - only whitespace, does nothing
2. `005_zsh_xdg.sh` line 23 creates `history` as directory, but `HISTFILE` expects a file

## Tasks

### 7.1 Fix or remove 000_path.zsh
Location: `stow/zsh/.oh-my-zsh/custom/zshrc.d/000_path.zsh`

Options:
a) Delete if Sprint 1 removes this directory
b) Add actual PATH modifications if needed
c) Keep as placeholder with comment

Recommend: Delete (covered by Sprint 1).

### 7.2 Fix zsh_xdg.sh history creation
Location: `stow/bootstrap/.system-bootstrap.d/005_zsh_xdg.sh`

Current (broken):
```bash
mkdir -p "${XDG_STATE_HOME}/zsh/history"
```

Should be:
```bash
mkdir -p "${XDG_STATE_HOME}/zsh"
touch "${XDG_STATE_HOME}/zsh/history"
```

### 7.3 Test
- Run bootstrap script
- Verify `~/.local/state/zsh/history` is a file
- Verify zsh history works

## Files Affected

```
stow/zsh/.oh-my-zsh/custom/zshrc.d/000_path.zsh (delete)
stow/bootstrap/.system-bootstrap.d/005_zsh_xdg.sh (fix)
```

## Acceptance Criteria

- [ ] No empty placeholder files
- [ ] history is a file, not directory
- [ ] Zsh history persists correctly
