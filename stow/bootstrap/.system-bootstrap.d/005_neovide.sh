#!/bin/bash
set -euo pipefail

echo "==> Installing Neovide..."

if command -v brew &>/dev/null; then
    brew install --cask neovide
else
    echo "Homebrew not found, skipping Neovide install"
    exit 1
fi

echo "==> Neovide installed"
