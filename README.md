# Jan Riethmayers Dot Files #

This is my dot-file way! :D

## Installation ##

    git clone http://github.com/riethmayer/dotfiles/
    cd dotfiles
    rake install # TODO add rake task
    
## Environment ##

I'm on Mac OS X and I just changed to zsh 6 months ago. So there may be some issues I never stumbled upon till now :) I love my mac, but I'd like to use these configs on my server too, which will be debian I think.

So for now, these settings are tested for Mac OS X only.

## Features ##

### Ruby version manager (rvm)

rvm overwrites my .gemrc settings after install. But I'd like to skip the documentation part as it only kills time, space, and wasted energy for our environment during the download :D (this is my contribution to green-it .gemrc !)

    gem: --no-rdoc --no-ri

### ZSH

In case I learn how to manage sub-modules in git, I'll add my zshkit here too. #TODO

### IRB

Some tweeks to my irb, like herb, autocomplete, sql to stdout.
I'll add some methods here too, like Object#local_methods.

### Autotest

Autotest-config. I screwed it up at the moment. #TODO

### Emacs

As with zsh, this should be a kind of sub-module too. #TODO