[ -f /opt/boxen/env.sh ] && source /opt/boxen/env.sh
export DOTFILES=/Users/riethmayer/src/dotfiles
source $DOTFILES/bash/env
source $DOTFILES/bash/aliases
source $DOTFILES/bash/config
source $DOTFILES/bash/git
source $DOTFILES/bash/ruby
[ -f $HOME/.aws_bonusbox ] && source $HOME/.aws_bonusbox
[ -f $HOME/.travis ] && source $HOME/.travis/travis.sh
