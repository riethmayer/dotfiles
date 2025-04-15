#!/bin/bash

# Exit on error
set -e

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Install mise if not already installed
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    brew install mise
fi

# Create necessary directories if they don't exist
mkdir -p ~/.config/mise
mkdir -p ~/.local/share/mise

# Stow the mise configuration
cd "$(dirname "$0")/../../.."
stow mise

# Initialize mise
mise install

echo "mise setup complete!" 