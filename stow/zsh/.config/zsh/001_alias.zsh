# Aliases
# Common command shortcuts

alias dc="docker-compose"
alias v=nvim
alias vim=nvim
alias tg=terragrunt
alias t=tmux

# Obsidian
export OBSIDIAN_VAULT="$HOME/obsidian/riethmayer"
alias oo='cd $OBSIDIAN_VAULT'
alias or='nvim $OBSIDIAN_VAULT/inbox/*.md'

# Syntax highlighting with Chroma
export LESSOPEN='| p() { chroma --fail "$1" || cat "$1"; }; p "%s"'

# Fonts
alias nerdfonts='fc-list : family | grep Nerd'

# Task Master aliases
alias tm='task-master'
alias taskmaster='task-master'

# EagleEye worktrees
alias w1='cd ~/code/ee-one/apps/eagleeye-web'
alias w2='cd ~/code/ee-two/apps/eagleeye-web'
alias w3='cd ~/code/ee-three/apps/eagleeye-web'
alias w4='cd ~/code/ee-four/apps/eagleeye-web'

# Claude Code
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
alias yolo='claude --dangerously-skip-permissions --model opus'
