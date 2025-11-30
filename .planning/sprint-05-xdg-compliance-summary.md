# Sprint 5: XDG Compliance - Summary

## Completed: 2025-11-30

## Changes Made
- Migrated `stow/git/.gitconfig` → `stow/git/.config/git/config`
- Migrated `stow/ruby/.gemrc` → `stow/ruby/.config/gem/gemrc`
- Added Ruby/Gem XDG environment variables to `stow/zsh/.config/zsh/000_environment.zsh`
- Updated tmux config to use XDG plugin path (`~/.local/share/tmux/plugins`)
- Updated `stow/bootstrap/.system-bootstrap.d/002_tmux.sh` to use XDG paths
- Added documentation comment in `003_gpg.sh` about GPG's XDG limitations
- Re-stowed git and ruby packages to create proper symlinks

## Verification
- Git reads config from `~/.config/git/config` ✓
- Ruby gemrc location at `~/.config/gem/gemrc` ✓
- Tmux plugin path configured for `~/.local/share/tmux/plugins` ✓
- Environment variables added for GEM_HOME, GEM_SPEC_CACHE, GEMRC ✓
- Bootstrap scripts updated to use XDG paths ✓

## Notes
- GPG cannot be migrated to XDG (hardcoded `~/.gnupg`)
- SSH cannot be migrated to XDG (OpenSSH requirement)
- Gem environment variables will take effect after shell restart
- Tmux plugins will migrate to XDG path on next TPM update