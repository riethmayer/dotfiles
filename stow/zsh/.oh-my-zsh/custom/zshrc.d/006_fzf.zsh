# Fuzzy Finder (see https://www.youtube.com/watch?v=qgG5Jhi_Els)
# Find files: CMD+t
# Change directory: OPT+c
# https://github.com/junegunn/fzf?tab=readme-ov-file#examples
export FZF_DEFAULT_OPTS='--height 50% --tmux bottom,40% --layout reverse --border top'
# Preview file content using bat
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"
source <(fzf --zsh)

if [[ -f $HOME/src/fzf-git.sh/fzf-git.sh ]]; then
  source $HOME/src/fzf-git.sh/fzf-git.sh
fi

