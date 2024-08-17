
alias dc="docker-compose"
alias v=nvim
alias vim=nvim
alias tg=terragrunt
alias t=tmux

export OBSIDIAN_VAULT="$HOME/obsidian/riethmayer"
# Obsidian
alias oo='cd $OBSIDIAN_VAULT'
alias or='nvim $OBSIDIAN_VAULT/inbox/*.md'

# Syntax highlighting with Chroma

export LESSOPEN='| p() { chroma --fail "$1" || cat "$1"; }; p "%s"'

