#!/bin/bash

# Create Windsurf directories if they don't exist
mkdir -p ~/.codeium/windsurf/bin

# Download and install Windsurf binary if not already installed
if ! command -v windsurf >/dev/null 2>&1; then
    echo "Installing Windsurf..."
    curl -fsSL https://codeium.com/windsurf/install.sh | sh
fi

# Instructions for using Windsurf
cat << 'EOF'
Windsurf setup complete!

The binary is installed in ~/.codeium/windsurf/bin
and the PATH is configured in ~/.oh-my-zsh/custom/zshrc.d/100_windsurf.zsh

To verify the installation:
windsurf --version

For more information, visit:
https://codeium.com/windsurf
EOF 