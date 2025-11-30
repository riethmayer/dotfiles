#!/bin/bash

# Install Atuin for shell history management
# https://atuin.sh/

set -e

echo "Installing Atuin..."

# Check if atuin is already installed
if command -v atuin &> /dev/null; then
    echo "Atuin is already installed"
    exit 0
fi

# Install atuin using Homebrew
if command -v brew &> /dev/null; then
    echo "Installing Atuin via Homebrew..."
    brew install atuin
else
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Create XDG directories for atuin
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/atuin"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/atuin"
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/atuin"

echo "Atuin installation completed"
