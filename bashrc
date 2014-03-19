export DOTFILES=/Users/riethmayer/src/dotfiles
source $DOTFILES/bash/env
source $DOTFILES/bash/aliases
source $DOTFILES/bash/config
source $DOTFILES/bash/git
source $DOTFILES/bash/ruby
source $DOTFILES/bash/go
source $DOTFILES/bash/bi_tools
[ -f $HOME/.aws_bonusbox ] && source $HOME/.aws_bonusbox
# added by travis gem
[ -f $HOME/.travis ] && source $HOME/.travis/travis.sh
eval "$(/Users/riethmayer/bonusbox/projects/bb/bin/bb init -)"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
