# mise Configuration
# mise is our version manager for multiple programming languages and tools

# Ensure XDG compliance for mise
export MISE_DATA_DIR="${XDG_DATA_HOME}/mise"
export MISE_CONFIG_DIR="${XDG_CONFIG_HOME}/mise"
export MISE_CACHE_DIR="${XDG_CACHE_HOME}/mise"

# Initialize mise shell integration
eval "$(mise activate zsh)"

# Add mise shims to PATH
export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH" 