#!/bin/bash

# Create bin directory if it doesn't exist
mkdir -p "$HOME/bin"

# Download and install asdf binary
echo "Installing asdf..."
curl -L https://github.com/asdf-vm/asdf/releases/latest/download/asdf-darwin-arm64 -o "$HOME/bin/asdf"
chmod +x "$HOME/bin/asdf"

# Create asdf data directory
mkdir -p "$HOME/.asdf/shims"

# Verify installation
if ! command -v asdf &> /dev/null; then
    echo "Error: asdf installation failed"
    exit 1
fi

echo "asdf installed successfully" 