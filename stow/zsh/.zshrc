# Set XDG Base Directory paths first
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# Load XDG-compliant configurations
# All zsh configs are in $XDG_CONFIG_HOME/zsh/
for config_file ($XDG_CONFIG_HOME/zsh/*.zsh(N)); do
    source $config_file
done
