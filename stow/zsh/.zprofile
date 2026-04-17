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

# mise shims — only for non-interactive login shells (GUI launches like Neovide Dock).
# Interactive shells get shims via `mise activate zsh` in .zshrc fragments.
if [[ ! -o interactive ]]; then
    export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"
fi
