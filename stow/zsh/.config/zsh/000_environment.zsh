# Basic environment settings
export PATH=$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export ARCHFLAGS="-arch arm64"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Man path
export MANPATH="/usr/local/man:$MANPATH"
export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}" 