# Sprint 1: Zsh Config Consolidation

## Problem

Two parallel config trees causing double-loading:
- `.oh-my-zsh/custom/zshrc.d/*.zsh` (legacy location)
- `.config/zsh/*.zsh` (XDG location)

Duplicated configs:
- oh-my-zsh sourced 2x
- atuin init 2x
- pnpm config 2x
- gcloud config 2x
- editor vars 2x
- XDG vars defined 3x

## Decision Required

**Keep XDG path** (`.config/zsh/`) - aligns with XDG compliance goal.

## Tasks

### 1.1 Audit both directories
```
stow/zsh/.oh-my-zsh/custom/zshrc.d/
stow/zsh/.config/zsh/
```
Compare file-by-file, identify unique vs duplicate content.

### 1.2 Merge unique content
Move any unique configs from `.oh-my-zsh/custom/zshrc.d/` into `.config/zsh/`.

### 1.3 Update .zshrc
- Remove sourcing of `.oh-my-zsh/custom/zshrc.d/`
- Keep only `.config/zsh/` sourcing
- Consolidate XDG var definitions to single location

### 1.4 Renumber .config/zsh/ files
Follow documented pattern:
- 000-009: Core environment
- 010-029: Package managers
- 030-049: Cloud tools
- 050-069: Programming languages
- 070-089: Development tools
- 090-099: Shell enhancements

### 1.5 Remove legacy directory
Delete `stow/zsh/.oh-my-zsh/custom/zshrc.d/` after migration complete.

### 1.6 Test
- Source new config
- Verify no duplicate initialization
- Check all tools load correctly

## Files Affected

```
stow/zsh/.zshrc
stow/zsh/.config/zsh/*.zsh
stow/zsh/.oh-my-zsh/custom/zshrc.d/*.zsh (delete)
```

## Acceptance Criteria

- [ ] Single source of truth for zsh configs
- [ ] No duplicate tool initialization
- [ ] XDG vars defined once
- [ ] All existing functionality preserved
