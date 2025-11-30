# Sprint 6: Missing Stow Packages

## Problem

Tools with configs not tracked in stow:
- `opencode` - handled in Sprint 3
- `kitty` - exists at `~/.config/kitty/kitty.conf`
- `nvim` - cloned from separate repo
- `gcloud` - referenced in .gitignore but no package

## Tasks

### 6.1 Add kitty package
```
stow/kitty/.config/kitty/kitty.conf
```
Copy existing config from `~/.config/kitty/`.

### 6.2 Document nvim approach
Nvim config is separate repo (git@github.com:riethmayer/nvim.git).
Options:
a) Keep separate (document in README)
b) Add as git submodule
c) Import into stow/nvim

Recommend: Keep separate, add to README.

### 6.3 Create gcloud package (optional)
Either:
a) Create `stow/gcloud/.config/gcloud/` with base config
b) Remove reference from .gitignore

gcloud stores credentials in config dir - may not want in dotfiles.

### 6.4 Update .gitignore
Clean up references to non-existent packages.

### 6.5 Update README
Document:
- Which tools are stowed
- Which tools have separate repos
- Which tools are excluded intentionally

## Files to Create

```
stow/kitty/.config/kitty/kitty.conf
```

## Files to Update

```
.gitignore
README.md
```

## Acceptance Criteria

- [ ] kitty config tracked
- [ ] nvim approach documented
- [ ] gcloud decision made and implemented
- [ ] README reflects reality
