# Sprint 4: Bootstrap Script Fixes

## Problem

Numbering collisions in `.system-bootstrap.d/`:
- `001_mise.sh` + `001_tmux.sh` share prefix
- `003_nvim.sh` + `003_windsurf.sh` share prefix

## Tasks

### 4.1 Renumber scripts
Proposed new numbering:
```
000_homebrew.sh   (unchanged)
001_mise.sh       (unchanged)
002_tmux.sh       (was 001)
003_gpg.sh        (was 002)
004_nvim.sh       (was 003)
005_windsurf.sh   (was 003)
006_atuin.sh      (was 004)
007_zsh_xdg.sh    (was 005)
040_gcloud.sh     (was 035)
```

### 4.2 Update any references
Check if any scripts reference others by name.

### 4.3 Test bootstrap
Run `mise run bootstrap` and verify order.

## Files Affected

```
stow/bootstrap/.system-bootstrap.d/001_tmux.sh -> 002_tmux.sh
stow/bootstrap/.system-bootstrap.d/002_gpg.sh -> 003_gpg.sh
stow/bootstrap/.system-bootstrap.d/003_nvim.sh -> 004_nvim.sh
stow/bootstrap/.system-bootstrap.d/003_windsurf.sh -> 005_windsurf.sh
stow/bootstrap/.system-bootstrap.d/004_atuin.sh -> 006_atuin.sh
stow/bootstrap/.system-bootstrap.d/005_zsh_xdg.sh -> 007_zsh_xdg.sh
stow/bootstrap/.system-bootstrap.d/035_gcloud.sh -> 040_gcloud.sh
```

## Acceptance Criteria

- [ ] No duplicate prefixes
- [ ] Logical ordering preserved
- [ ] Bootstrap runs successfully
