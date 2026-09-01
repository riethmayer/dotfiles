#!/bin/bash

# Install the swamp CLI (AI-native automation; https://swamp.club).
#
# Canonical installer: `curl -fsSL https://swamp.club/install.sh | sh`. It
# picks ~/.local/bin only when that dir is already on PATH and otherwise falls
# back to ~/.swamp/bin plus a sudo symlink into /usr/local/bin, so pass the
# destination explicitly to keep bootstrap prompt-free and the binary where
# 000_environment.zsh expects it. swamp ships a self-updater (`swamp update`,
# daily builds), so install only when the binary is missing and never clobber
# a self-updated copy. Zsh completions are cached lazily by 074_swamp.zsh on
# first interactive shell — nothing to do here.
#
# SWAMP_INSTALL_DIR overrides the destination (used to test the install path).

set -euo pipefail

SWAMP_INSTALL_DIR="${SWAMP_INSTALL_DIR:-$HOME/.local/bin}"

if command -v swamp >/dev/null 2>&1; then
    echo "swamp: already installed ($(swamp --version 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' || echo unknown)) — \`swamp update\` owns upgrades, skipping install"
else
    command -v curl >/dev/null 2>&1 || { echo "swamp: curl not found" >&2; exit 1; }
    curl -fsSL https://swamp.club/install.sh | sh -s -- -d "$SWAMP_INSTALL_DIR"
    echo "swamp: installed $("$SWAMP_INSTALL_DIR/swamp" --version 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' || echo unknown) to $SWAMP_INSTALL_DIR"
fi

echo "swamp setup complete!"
