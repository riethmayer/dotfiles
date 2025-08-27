# Configure history behavior
export HISTSIZE=1000000
export SAVEHIST=1000000

# Set XDG-compliant history file location
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

# Use Atuin to manage history if available
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
    
    # Bind keyboard shortcuts for Atuin
    bindkey '^[[A' _atuin_search_widget  # Up arrow
    bindkey '^[OA' _atuin_search_widget  # Up arrow (alternative code)
    bindkey '^P' _atuin_search_widget    # Ctrl+P
else
    echo "Warning: atuin not found. Shell history enhancement not available."
    echo "Run 'make bootstrap' to install atuin."
fi