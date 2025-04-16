# Use Atuin to manage history
eval "$(atuin init zsh)"

# Configure history behavior
export HISTSIZE=1000000
export SAVEHIST=1000000

# Bind keyboard shortcuts for Atuin
bindkey '^[[A' _atuin_search_widget  # Up arrow
bindkey '^[OA' _atuin_search_widget  # Up arrow (alternative code)
bindkey '^P' _atuin_search_widget    # Ctrl+P