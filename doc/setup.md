# Setting up a new OS

## 0. remove caps-lock 

## 1. git
 * Download installer at http://code.google.com/p/git-osx-installer/
 * install pkg
 * setup git path for non-terminal apps

## 2. xcode
 * install xcode from cd to /Developer

## 3. configure german and english language and shortcuts
 * set next language to alt+cmd+f12
 * Nächsten Tab auswählen shift+cmd+]
 * Vorherigen Tab auswählen shift+cmd+[

## 4. install zshkit and emacs

### zshkit

    # open terminal preferences and change 'open shell with' to /bin/zsh
    
    git clone git@github.com:riethmayer/zshkit.git ~/code/zshkit
    chmod +x ~/code/zshkit/install && ~/code/zshkit/install

### emacs

    git clone git@github.com:riethmayer/emacs.git ~/code/emacs
    cd ~/code/emacs
    ruby install.rb

## 5. save ssh credentials

## 6. change hostname
 * sudo hostname -s Kamehameha

## 7. configure delicious bookmarks

add bookmarks from here
 * http://delicious.com/help/bookmarklets

## 8. install macports
 * download at http://distfiles.macports.org/MacPorts
 
## 9. install mysql 

seen at http://hivelogic.com/articles/compiling-mysql-on-snow-leopard/

### download

    # download at http://opensource.become.com/mysql/Downloads/MySQL-5.1/
    mkdir ~/src
    cd ~/src
    curl -O http://opensource.become.com/mysql/Downloads/MySQL-5.1/mysql-5.1.39.tar.gz

### unpack it
    
    tar -xf mysql-5.1.39.tar.gz
    cd mysql-5.1.39
    
### compile and install

    ./configure --prefix=/usr/local/mysql --with-extra-charsets=complex \
      --enable-thread-safe-client --enable-local-infile --enable-shared \
      --with-plugins=innobase

    make
    sudo make install

    cd /usr/local/mysql
    sudo ./bin/mysql_install_db --user=mysql
    sudo chown -R mysql ./var
    cd ..

### add path variable to zshkit/env
    
    export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:$PATH"

### configure mysql to autostart

#### get hivelogics awesome plist
    
    cd ~/src
    curl -O http://hivelogic.com/downloads/com.mysql.mysqld.plist
    sudo mv ~/src/com.mysql.mysqld.plist /Library/LaunchDaemons
    sudo chown root /Library/LaunchDaemons/com.mysql.mysqld.plist

#### tell launchd to load and startup mysql    
    
     sudo launchctl load -w /Library/LaunchDaemons/com.mysql.mysqld.plist

#### install ruby gem

    gem install mysql -- --with-mysql-dir=/usr/local/mysql 

10. install quicksilver
 * http://www.blacktree.com/

Continue setting up ruby stuff.
