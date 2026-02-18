#!/bin/bash

# Exit on error
set -e

# Install claude if not present
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Stow claude configuration
cd "$(dirname "$0")/../../.."
stow -d stow -t ~ claude

echo "Claude Code setup complete!"
