# mise Configuration
# Version manager for multiple programming languages and tools
# Requires: mise (installed via brew)

# Check if mise is available
if command -v mise >/dev/null 2>&1; then
    # Ensure XDG compliance for mise
    export MISE_DATA_DIR="${XDG_DATA_HOME}/mise"
    export MISE_CONFIG_DIR="${XDG_CONFIG_HOME}/mise"
    export MISE_CACHE_DIR="${XDG_CACHE_HOME}/mise"

    # Initialize mise shell integration
    eval "$(mise activate zsh)"

    # Add mise shims to PATH
    export PATH="${MISE_DATA_DIR}/shims:$PATH"
else
    echo "Warning: mise not found. Version management not available."
fi 