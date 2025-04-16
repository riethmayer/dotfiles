# mise configuration and shell integration
eval "$(mise activate zsh)"

# Add mise shims to PATH
export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH" 