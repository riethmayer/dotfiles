export MANPATH="/usr/local/man:$MANPATH"
export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch arm64"

# Load custom configurations from Oh My Zsh custom directory
for config_file ($ZSH_CUSTOM/zshrc.d/*.zsh(N)); do
  source $config_file
done

# Set XDG Base Directory paths first
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# Source environment configuration first
source "${XDG_CONFIG_HOME}/zsh/000_environment.zsh"

# Set Oh My Zsh path using XDG location
export ZSH="${XDG_DATA_HOME}/oh-my-zsh"

# Basic Oh My Zsh configuration
ZSH_THEME=""
plugins=(git colored-man-pages)

# Source Oh My Zsh
source "${ZSH}/oh-my-zsh.sh"

# Source remaining configurations
for config_file ($XDG_CONFIG_HOME/zsh/0[1-9]*.zsh(N)); do
  source $config_file
done

# Everything that comes after this line should be moved to dotfiles/stow/zsh
