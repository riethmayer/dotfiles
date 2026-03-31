# Tmux Configuration
# Terminal multiplexer

export TMUX_PLUGIN_MANAGER_PATH="${XDG_DATA_HOME}/tmux/plugins"
export TMUX_TMPDIR="${XDG_STATE_HOME}/tmux"

# Create tmux state directory if needed
mkdir -p "${TMUX_TMPDIR}"

# Set pane title to git branch (dirty state) or directory name
if [[ -n "$TMUX" ]]; then
  _tmux_pane_title_last=0
  _tmux_pane_title_precmd() {
    local now
    now=$EPOCHSECONDS
    # Throttle: update at most every 5 seconds
    (( now - _tmux_pane_title_last < 5 )) && return
    _tmux_pane_title_last=$now

    local branch dirty title
    branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
      git diff --quiet 2>/dev/null || dirty="*"
      title="${branch}${dirty}"
    else
      title="${PWD##*/}"
    fi
    printf '\033]2;%s\033\\' "$title"
  }
  precmd_functions+=(_tmux_pane_title_precmd)
fi
