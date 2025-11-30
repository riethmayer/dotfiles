# Sprint 4: Bootstrap Script Fixes - Summary

## Completed: 2025-11-30

## Changes Made
- Renamed `stow/bootstrap/.system-bootstrap.d/001_tmux.sh` → `002_tmux.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/002_gpg.sh` → `003_gpg.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/003_nvim.sh` → `004_nvim.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/003_windsurf.sh` → `005_windsurf.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/004_atuin.sh` → `006_atuin.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/005_zsh_xdg.sh` → `007_zsh_xdg.sh`
- Renamed `stow/bootstrap/.system-bootstrap.d/035_gcloud.sh` → `040_gcloud.sh`
- Updated `.mise.toml` task references for all renamed scripts
- Set executable permissions on scripts that needed it

## Verification
- No more duplicate prefixes (001 and 003 collisions resolved)
- Logical ordering preserved (homebrew → mise → tmux → gpg → nvim → windsurf → atuin → zsh_xdg → gcloud)
- All mise tasks reference correct script paths
- Bootstrap commands tested with `mise run help`

## Notes
- Bootstrap script order is now clear and collision-free
- All references in `.mise.toml` have been updated to match new numbering