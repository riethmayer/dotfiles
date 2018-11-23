# dotfiles

Simple dotfiles file.

I'm setting up my dotfiles with ansible.
Have a look at [my ansible bootstrap setup](https://github.com/riethmayer/ansible_osx_bootstrap).

## Installation

Clone the dotfiles repository to your target dotfiles directory.

    mkdir -p $HOME/src
    git clone git@github.com:riethmayer/dotfiles $HOME/src/dotfiles

Link your config files: (this is managed for me via ansible)

    # YMMV
    ln -s $DOTFILES_DIR/gemrc $HOME/.gemrc
    ln -s $DOTFILES_DIR/tmux.conf $HOME/.tmux.conf
    ln -s $DOTFILES_DIR/gitconfig $HOME/.gitconfig
    ln -s $DOTFILES_DIR/bin $HOME/bin
    ln -s $DOTFILES_DIR/bash/profile $HOME/.profile
    ln -s $DOTFILES_DIR/bash/bash_profile $HOME/.bash_profile

## FZF

https://github.com/junegunn/fzf#using-homebrew-or-linuxbrew
