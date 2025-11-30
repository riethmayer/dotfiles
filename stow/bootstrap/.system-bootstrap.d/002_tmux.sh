# Install tmux if not already installed
if ! command -v tmux >/dev/null 2>&1; then
    brew install tmux
fi

# Install dependencies for tmux plugins
brew install fzf    # Required for tmux-fzf and tmux-sessionx
brew install zoxide # Required for tmux-sessionx zoxide mode

# Create tmux directories if they don't exist
mkdir -p ~/.tmux/plugins
mkdir -p ~/.config/tmux
mkdir -p ~/.local/state/tmux/log  # XDG state directory for logs

# Install Tmux Plugin Manager if not already installed
TPM_PATH=~/.tmux/plugins/tpm
if [ ! -d "$TPM_PATH" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
fi

# Install/Update tmux plugins non-interactively
~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all

# Ensure tmux server is running and reload config
TMUX_TMPDIR=~/.local/state/tmux tmux start-server
TMUX_TMPDIR=~/.local/state/tmux tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
