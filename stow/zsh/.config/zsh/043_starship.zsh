# Starship Configuration
# Cross-shell prompt customization
# https://starship.rs/

# Use XDG-compliant paths
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship.toml"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# Initialize starship if available
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
