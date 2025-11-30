# Oh My Zsh Configuration
# Framework for managing zsh configuration and plugins

# Set Oh My Zsh paths using XDG standards (must be set before sourcing)
export ZSH="${XDG_DATA_HOME}/oh-my-zsh"
export ZSH_CUSTOM="${ZSH}/custom"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/oh-my-zsh"
mkdir -p "${ZSH_CACHE_DIR}"

# Theme configuration (using starship prompt instead)
ZSH_THEME=""

# Plugins
plugins=(
    git
    colored-man-pages
    command-not-found
    docker
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# History Configuration
HIST_STAMPS="yyyy-mm-dd"
DISABLE_AUTO_UPDATE="true"

# Load Oh My Zsh
source "${ZSH}/oh-my-zsh.sh" 