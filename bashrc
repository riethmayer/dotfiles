# loading source files
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi
source /usr/local/etc/bash_completion.d/git-completion.bash
export DOTFILES=/Users/riethmayer/Projects/github/dotfiles
source $DOTFILES/bash/env
source $DOTFILES/bash/aliases
source $DOTFILES/bash/config
