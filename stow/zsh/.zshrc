export PATH=$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(git colored-man-pages)

# User configuration

export MANPATH="/usr/local/man:$MANPATH"
export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch arm64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#

# Source all zsh configuration files
ZSHRC_D="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Source base configuration files (ensures OMZ core loads early)
for file in "$ZSHRC_D/"*.zsh; do
    source "$file"
done

# Everything that comes after this line should be moved to dotfiles/stow/zsh

PATH=~/.console-ninja/.bin:$PATH