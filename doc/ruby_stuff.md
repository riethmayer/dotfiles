# gemcutter

    sudo gem update --system
    sudo gem install gemcutter
    sudo gem tumble

# ruby version manager

    gem install rvm
    rvm-install

(follow prompts)

## install ruby versions
    rvm install 1.8.6
    rvm install 1.8.7
    rvm install 1.9.1
    rvm install 1.9.2
    rvm install ree
    rvm install jruby
    rvm use 1.8.7 --default

# RMagick

    sudo port install tiff -macosx imagemagick +q8 +gs +wmf
    gem install rmagick

# MacRuby

## install LLVM first

    git clone git://repo.or.cz/llvm.git
    cd llvm
    git checkout -b macruby-reliable ebe2d0079b086caa4d68ea9b63397751e4df6564
    ./configure
    UNIVERSAL=1 UNIVERSAL_ARCH="i386 x86_64" ENABLE_OPTIMIZED=1 make
    sudo env UNIVERSAL=1 UNIVERSAL_ARCH="i386 x86_64" ENABLE_OPTIMIZED=1 make install

