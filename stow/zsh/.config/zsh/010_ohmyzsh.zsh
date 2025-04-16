# Oh My Zsh Configuration
# Framework for managing zsh configuration and plugins

# Additional plugins beyond the basic set in .zshrc
plugins+=(
    command-not-found   # Suggest package installation for unknown commands
    docker             # Docker commands and completion
    zsh-autosuggestions # Fish-like autosuggestions
    zsh-syntax-highlighting # Syntax highlighting for commands
)

# History Configuration
HIST_STAMPS="yyyy-mm-dd" # Use ISO date format for history
DISABLE_AUTO_UPDATE="true" # Disable auto-updates (managed by mise)

# Cache directory
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/oh-my-zsh"
mkdir -p "${ZSH_CACHE_DIR}"

# Set Oh My Zsh installation path using XDG standards
export ZSH="${XDG_DATA_HOME}/oh-my-zsh"
export ZSH_CUSTOM="${ZSH}/custom"

# Theme configuration
# Using starship prompt instead of Oh My Zsh theme
ZSH_THEME=""

# Load Oh My Zsh
source "${ZSH}/oh-my-zsh.sh" 