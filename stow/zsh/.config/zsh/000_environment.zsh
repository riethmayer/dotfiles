# Basic PATH configuration
# Add user binaries and local binaries to PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew initialization and path
eval "$(/opt/homebrew/bin/brew shellenv)"

# Language and System Settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export ARCHFLAGS="-arch arm64"

# mise path configuration
export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"

# Additional PATH modifications
export PATH="/usr/local/sbin:$PATH"

# Man path configuration
export MANPATH="/usr/local/man:$MANPATH"
export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}"

# Editor configuration
export EDITOR='nvim'
export VISUAL='nvim'

# History configuration
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000 