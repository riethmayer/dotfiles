export MANPATH="/usr/local/man:$MANPATH"
export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch arm64"

# Set XDG Base Directory paths first
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# Set Oh My Zsh path using XDG location
export ZSH="${XDG_DATA_HOME}/oh-my-zsh"

# Basic Oh My Zsh configuration
ZSH_THEME=""
plugins=(git colored-man-pages)

# Source Oh My Zsh
source "${ZSH}/oh-my-zsh.sh"

# Load custom configurations from Oh My Zsh custom directory
for config_file ($ZSH_CUSTOM/zshrc.d/*.zsh(N)); do
  source $config_file
done

# Load XDG-compliant configurations
for config_file ($XDG_CONFIG_HOME/zsh/*.zsh(N)); do
  source $config_file
done

