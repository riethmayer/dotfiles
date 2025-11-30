# Sprint 11: Final Cleanup

## Problem

Minor inconsistencies remain after sprints 1-10:
- Git aliases reference `master` but default branch is `main`
- `lua` installed via both brew and mise (duplication)
- `.brewfile.d/` indirection layer adds complexity
- Empty `.oh-my-zsh/` directory left in stow tree

## Tasks

### 11.1 Update git aliases to use `main`
Update `stow/git/.config/git/config`:
- `up` alias: `origin/master` → `origin/main`
- `down` alias: `master` → `main`

### 11.2 Remove lua from Brewfile
Edit `stow/brew/Brewfile`:
- Remove `brew 'lua'` (line 51)
- mise already manages lua 5.1.5

### 11.3 Simplify Homebrew bootstrap
- Delete `stow/bootstrap/.brewfile.d/` directory
- Update `stow/bootstrap/.system-bootstrap.d/000_homebrew.sh`:
  - Remove the `cat .brewfile.d/* | xargs brew install` line
  - Keep only `brew bundle --file`

### 11.4 Remove empty .oh-my-zsh directory
Delete `stow/zsh/.oh-my-zsh/` (empty, no longer needed)

## Files to Delete

```
stow/bootstrap/.brewfile.d/
stow/zsh/.oh-my-zsh/
```

## Files to Update

```
stow/git/.config/git/config
stow/brew/Brewfile
stow/bootstrap/.system-bootstrap.d/000_homebrew.sh
```

## Acceptance Criteria

- [ ] `git up` and `git down` work with `main` branch
- [ ] `lua` only managed by mise
- [ ] `000_homebrew.sh` uses single Brewfile source
- [ ] No empty directories in stow tree
- [ ] `mise run install` succeeds
- [ ] Fresh shell works
