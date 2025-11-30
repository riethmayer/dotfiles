# Sprint 5: XDG Compliance

## Problem

Several tools not following XDG spec:

| Tool | Current | XDG Path |
|------|---------|----------|
| git | `~/.gitconfig` | `~/.config/git/config` |
| ruby | `~/.gemrc` | `~/.config/gem/gemrc` |
| tmux plugins | `~/.tmux/plugins/` | `~/.local/share/tmux/plugins/` |

Note: SSH cannot be changed (OpenSSH hardcodes `~/.ssh/`).

## Tasks

### 5.1 Migrate git config
```
stow/git/.gitconfig -> stow/git/.config/git/config
```
Git natively supports `~/.config/git/config`.

### 5.2 Migrate ruby gemrc
```
stow/ruby/.gemrc -> stow/ruby/.config/gem/gemrc
```
Set `GEM_SPEC_CACHE` and `GEM_HOME` in zsh config.

### 5.3 Fix tmux plugin path
Update `tmux.conf`:
```
set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.local/share/tmux/plugins'
```
Move/update TPM installation path in bootstrap.

### 5.4 Update bootstrap scripts
Ensure XDG paths used in:
- `002_gpg.sh` (GPG can't change, document)
- `001_tmux.sh` (update plugin path)

### 5.5 Test each tool
- Git: `git config --list --show-origin`
- Ruby: `gem environment`
- Tmux: verify plugins load

## Files Affected

```
stow/git/.gitconfig -> stow/git/.config/git/config
stow/ruby/.gemrc -> stow/ruby/.config/gem/gemrc
stow/tmux/.config/tmux/tmux.conf
stow/bootstrap/.system-bootstrap.d/001_tmux.sh
```

## Acceptance Criteria

- [ ] Git reads from XDG path
- [ ] Gem reads from XDG path
- [ ] Tmux plugins in XDG data dir
- [ ] All tools function correctly
