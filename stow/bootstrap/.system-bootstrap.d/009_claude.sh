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

# Seed Claude Desktop config. It is deliberately NOT stowed (the app rewrites it
# at runtime — device name, account UUID, epitaxyPrefs; see
# stow/agents/.stow-local-ignore), so copy the committed seed only when absent.
# This never clobbers an existing live config.
desktop_config_dir="$HOME/Library/Application Support/Claude"
desktop_config="$desktop_config_dir/claude_desktop_config.json"
desktop_seed="stow/agents/Library/Application Support/Claude/claude_desktop_config.json"
if [ ! -e "$desktop_config" ]; then
    echo "Seeding Claude Desktop config..."
    mkdir -p "$desktop_config_dir"
    cp "$desktop_seed" "$desktop_config"
fi

echo "Claude Code setup complete!"
