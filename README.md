# dotfiles

Simple dotfiles file.

## Installation
Clone the dotfiles repository to your target dotfiles directory.

    mkdir -p $HOME/src
    git clone git@github.com:riethmayer/dotfiles $HOME/src/dotfiles

Then edit your `$HOME/.bash_profile` file to look like this:

    # $HOME/.bash_profile
    export DOTFILES_DIR=$HOME/src/dotfiles
    source $DOTFILES_DIR/bash/env
    source $DOTFILES_DIR/bash/aliases

Link your config files:

    # YMMV
    ln -s $DOTFILES_DIR/gemrc $HOME/.gemrc
    ln -s $DOTFILES_DIR/tmux.conf $HOME/.tmux.conf
    ln -s $DOTFILES_DIR/gitconfig $HOME/.gitconfig
    ln -s $DOTFILES_DIR/bin $HOME/bin

