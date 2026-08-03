#!/bin/bash

# Install the treehouse CLI (pooled git worktrees for parallel agent
# workflows) and stow its user-level config (max_trees).
#
# Installed via go: github.com/kunchenguid/treehouse tags v2.x without a /v2
# module path, so `go install @latest` resolves to a main-branch
# pseudo-version — the same shape as the manually installed binary this
# replaces. treehouse ships a self-updater, so install only when the binary
# is missing and never clobber a self-updated copy.

set -euo pipefail

# Resolve the repo root physically: $0 may be the stowed
# ~/.system-bootstrap.d/<script> path, where a logical ../../.. walks out of
# $HOME instead of into the repo.
cd "$(cd "$(dirname "$0")" && pwd -P)/../../.."

if command -v treehouse >/dev/null 2>&1; then
    echo "treehouse: already installed ($(treehouse --version 2>/dev/null || echo unknown)) — self-updater owns upgrades, skipping install"
else
    command -v go >/dev/null 2>&1 || { echo "treehouse: go not found (run mise install first)" >&2; exit 1; }
    GOBIN="$HOME/.local/bin" go install github.com/kunchenguid/treehouse@latest
    echo "treehouse: installed $(treehouse --version 2>/dev/null || echo unknown) to ~/.local/bin"
fi

stow -d stow -t ~ treehouse
echo "treehouse setup complete!"
