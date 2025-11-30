# Sprint 2: Claude Config Cleanup

## Problem

Identical files in both locations:
- `stow/claude/.claude/` (correct - Claude Code uses this)
- `stow/claude/.config/claude/` (incorrect - redundant)

Claude Code doesn't support XDG, uses `~/.claude/` hardcoded.

## Tasks

### 2.1 Verify Claude Code path
Confirm Claude Code only reads from `~/.claude/`.

### 2.2 Remove redundant directory
Delete `stow/claude/.config/claude/` entirely.

### 2.3 Update stow package
Ensure `stow/claude/` only contains `.claude/` directory.

### 2.4 Test
- Restow claude package
- Verify settings load correctly

## Files Affected

```
stow/claude/.config/claude/ (delete entire tree)
```

## Acceptance Criteria

- [ ] Only `~/.claude/` symlinked
- [ ] No duplicate configs
- [ ] Claude Code settings work
