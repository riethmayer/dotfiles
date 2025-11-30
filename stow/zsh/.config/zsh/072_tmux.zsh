# Tmux Configuration
# Terminal multiplexer

export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins"
export TMUX_TMPDIR="${XDG_STATE_HOME}/tmux"

# Create tmux state directory if needed
mkdir -p "${TMUX_TMPDIR}"
