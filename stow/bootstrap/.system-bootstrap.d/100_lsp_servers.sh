#!/bin/bash

# Install LSP servers for better editor support
# These provide IDE features for shell scripts, configs, and documentation

set -e

echo "Installing LSP servers for enhanced editor support..."

# Check if Node.js is available
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Installing via mise..."
    mise use --global node@lts
fi

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Please install Node.js first."
    exit 1
fi

# Install Homebrew-based LSP servers
echo "Installing Homebrew-based LSP servers..."

# Lua Language Server - for .lua configs
if ! command -v lua-language-server >/dev/null 2>&1; then
    echo "  Installing lua-language-server..."
    brew install lua-language-server
else
    echo "  lua-language-server already installed"
fi

# Taplo - TOML Language Server for .toml files
if ! command -v taplo >/dev/null 2>&1; then
    echo "  Installing taplo (TOML LSP)..."
    brew install taplo
else
    echo "  taplo already installed"
fi

# Marksman - Markdown LSP for .md files
if ! command -v marksman >/dev/null 2>&1; then
    echo "  Installing marksman (Markdown LSP)..."
    brew install marksman
else
    echo "  marksman already installed"
fi

# Install npm-based LSP servers
echo "Installing npm-based LSP servers..."

# Bash Language Server - for .sh, .bash, .zsh scripts
if ! command -v bash-language-server >/dev/null 2>&1; then
    echo "  Installing bash-language-server..."
    npm install -g bash-language-server
else
    echo "  bash-language-server already installed"
fi

# YAML Language Server - for .yml, .yaml files
if ! command -v yaml-language-server >/dev/null 2>&1; then
    echo "  Installing yaml-language-server..."
    npm install -g yaml-language-server
else
    echo "  yaml-language-server already installed"
fi

# VSCode Language Servers - includes JSON LSP
if ! npm list -g vscode-langservers-extracted >/dev/null 2>&1; then
    echo "  Installing vscode-langservers-extracted (JSON LSP)..."
    npm install -g vscode-langservers-extracted
else
    echo "  vscode-langservers-extracted already installed"
fi

echo ""
echo "LSP servers installed successfully!"
echo "Available LSP servers:"
echo "  - bash-language-server (shell scripts)"
echo "  - lua-language-server (Lua configs)"
echo "  - yaml-language-server (YAML files)"
echo "  - taplo (TOML configs)"
echo "  - vscode-json-language-server (JSON files)"
echo "  - marksman (Markdown docs)"
echo ""
echo "Configure these in your Neovim LSP config for enhanced editing."