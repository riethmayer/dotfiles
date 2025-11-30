#!/bin/bash

# Install neovim if not already installed
if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing neovim nightly..."
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
    tar xzf nvim-macos-arm64.tar.gz
    
    # Move to user's local directory instead of system directory
    mkdir -p $HOME/.local/opt
    mv nvim-macos-arm64 $HOME/.local/opt/nvim-nightly
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/opt/nvim-nightly/bin/nvim $HOME/.local/bin/nvim
    
    # Cleanup
    rm nvim-macos-arm64.tar.gz
fi

# Create neovim config directories
mkdir -p ~/.config

# Clone or update nvim config
NVIM_CONFIG="$HOME/.config/nvim"
if [ ! -d "$NVIM_CONFIG" ]; then
    echo "Cloning nvim configuration..."
    git clone git@github.com:riethmayer/nvim.git "$NVIM_CONFIG"
else
    echo "Updating nvim configuration..."
    # Stash any changes before pulling
    git -C "$NVIM_CONFIG" stash
    git -C "$NVIM_CONFIG" pull
    git -C "$NVIM_CONFIG" stash pop || true
fi

# Install package manager (lazy.nvim)
LAZY_PATH="$HOME/.local/share/nvim/lazy"
if [ ! -d "$LAZY_PATH" ]; then
    echo "Installing lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
        --branch=stable "$LAZY_PATH"
fi

# Instructions for using neovim
cat << 'EOF'
Neovim nightly setup complete!

Your configuration has been cloned from git@github.com:riethmayer/nvim.git
to ~/.config/nvim

The nvim binary is installed in ~/.local/bin/nvim
Make sure ~/.local/bin is in your PATH

To complete setup:
1. Open neovim: nvim
2. Lazy.nvim will automatically install plugins
3. Run :checkhealth to verify everything is working

Note: You may need to run :PackerSync or :Lazy sync
depending on your package manager configuration.
EOF 