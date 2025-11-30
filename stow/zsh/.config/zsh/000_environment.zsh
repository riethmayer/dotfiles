# Basic PATH configuration
# Add user binaries and local binaries to PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew initialization and path - portable across different architectures
if [ -f "/opt/homebrew/bin/brew" ]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Language and System Settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export ARCHFLAGS="-arch arm64"

# mise path configuration
export PATH="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims:$PATH"

# Additional PATH modifications
export PATH="/usr/local/sbin:$PATH"

# Man path configuration - portable across different architectures
export MANPATH="/usr/local/man:$MANPATH"
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnuman" ]; then
    export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:${MANPATH}"
fi

# Editor configuration
export EDITOR='nvim'
export VISUAL='nvim'

# Ruby/Gem XDG configuration
export GEMRC="${XDG_CONFIG_HOME:-$HOME/.config}/gem/gemrc"
export GEM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/gem"
export PATH="$GEM_HOME/bin:$PATH" 