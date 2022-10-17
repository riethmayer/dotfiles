# dotfiles

Simple dotfiles file.

## Installation

Clone the dotfiles repository to your target dotfiles directory.

    git clone git@github.com:riethmayer/dotfiles $HOME/.dotfiles
    export DOTFILES_DIR=$HOME/.dotfiles

Link your config files: (this is managed for me via ansible)

    # YMMV
    ln -s $DOTFILES_DIR/gemrc $HOME/.gemrc
    ln -s $DOTFILES_DIR/tmux.conf $HOME/.tmux.conf
    ln -s $DOTFILES_DIR/gitconfig $HOME/.gitconfig
    ln -s $DOTFILES_DIR/zshrc $HOME/.zshrc
    ln -s $DOTFILES_DIR/Rprofile $HOME/.Rprofile
