# Atuin Configuration
# Shell history search and sync tool

# History settings (atuin manages history, but keep these for compatibility)
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTFILE="${XDG_STATE_HOME}/zsh/history"

# Check if atuin is available
if command -v atuin >/dev/null 2>&1; then
    # Set XDG paths
    export ATUIN_CONFIG_DIR="${XDG_CONFIG_HOME}/atuin"
    export ATUIN_CACHE_DIR="${XDG_CACHE_HOME}/atuin"

    # Initialize atuin shell integration
    eval "$(atuin init zsh)"

    # Bind keyboard shortcuts for Atuin
    bindkey '^[[A' _atuin_search_widget  # Up arrow
    bindkey '^[OA' _atuin_search_widget  # Up arrow (alternative code)
    bindkey '^P' _atuin_search_widget    # Ctrl+P
fi 