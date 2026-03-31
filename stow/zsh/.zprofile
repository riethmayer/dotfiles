# Login shell environment — sourced by login shells (Neovide Dock launch, SSH, etc.)
# .zshrc also sources these via 000_environment.zsh for interactive shells

# Homebrew
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Core PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH"

# mise shims
export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
