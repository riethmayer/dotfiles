# Atuin Configuration
# Shell history search and sync tool
# Requires: atuin (installed via brew)

# Check if atuin is available
if command -v atuin >/dev/null 2>&1; then
    # Set XDG paths
    export ATUIN_CONFIG_DIR="${XDG_CONFIG_HOME}/atuin"
    export ATUIN_CACHE_DIR="${XDG_CACHE_HOME}/atuin"

    # Initialize atuin shell integration
    eval "$(atuin init zsh)"
else
    echo "Warning: atuin not found. Shell history enhancement not available."
fi 