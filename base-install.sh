#!/bin/bash

# SCRIPT TO INSTALL MY IMPORTANT DOTFILES AND PLUGINS TO USER DIR (RUN WITH SUDO)

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root! (use 'sudo')" 1>&2
	exit 1
fi

#### APT ####

read -p "Do you want to install required packages via apt? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Update sources
    apt update
    apt upgrade -y
    apt dist-upgrade -y

    # Install Reqired packages
    apt install curl build-essential zsh exfat-fuse exfat-utils software-properties-common python-software-properties -y
	ln -sv $HOME/dotfiles/.gitconfig $HOME
fi

### ADB and Fastboot ###

read -p "Do you want to install ADB and Fastboot? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
	unzip -d $HOME platform-tools-latest-linux.zip
	chmod +x ~/platform-tools/adb
	chmod +x ~/platform-tools/fastboot
fi

### Android Studio ###
### Source -> https://mfonville.github.io/android-studio/

read -p "Do you want to install Android Studio? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	add-apt-repository ppa:webupd8team/java -y
	apt-add-repository ppa:maarten-fonville/android-studio -y
	apt-get update
	apt-get install java-common oracle-java8-installer oracle-java8-set-default android-studio -y
fi

### Sublime Text ###

read -p "Do you want to install Sublime Text 3? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
	apt update
	apt-get install sublime-text -y
fi

### NVM ###
### Source -> http://yoember.com/nodejs/the-best-way-to-install-node-js/

read -p "Do you want to install Node Version Manager? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	apt-get purge nodejs
	apt autoremove
	apt autoclean
	curl -o- "https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh" | bash
	. $HOME/.bashrc
fi

### Golang ###
### Source -> https://github.com/canha/golang-tools-install-script

read -p "Do you want to install Golang? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	wget https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh
	bash goinstall.sh --64
	. $HOME/.bashrc
fi

### Python, pip and Virtualenv ###

echo "Installing Python, Python 3, pip and virtualenv"
apt-get install python3-dev python3-pip python-dev python-pip -y
sudo -H pip install --upgrade pip
sudo -H pip3 install --upgrade pip
sudo -H pip install --upgrade virtualenv
sudo -H pip install --upgrade virtualenvwrapper
mkdir ~/.virtualenvs

### pip packages ###

echo "Installing pip packages"
pip3 install pip-review youtube-dl

#### ZSH ####

read -p "Do you want to install Zsh themes, scripts and plugins? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Install Oh-My-Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # fzf for fuzzy searching the command line
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # Zsh-Autosuggestions
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions

    # Zsh-Syntax Highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting

    # Zsh Alias Tips
    cd ${ZSH_CUSTOM1:-$ZSH/custom}/plugins
    git clone https://github.com/djui/alias-tips.git

    # Spaceship zsh theme
    sh -c "$(curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh)"
    curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.zsh | zsh

    # Backup old .zshrc
    mv ~/.zshrc ~/.zshrc_backup

    # Symlink .zshrc from dotfiles
    ln -sv “~/dotfiles/.zshrc” ~
    
    # Update for now (only required if using zsh)
    . $HOME/.zshrc
fi

### Misc ###
read -p "Are you dual booting this system with Windows? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Fixing time inconsistency for a dual boot system"
	### Source -> http://www.webupd8.org/2014/09/dual-boot-fix-time-differences-between.html
	timedatectl set-local-rtc 1
fi

echo "Increasing inotify watches"
### Source -> https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf
sysctl -p

read -p "Do you want auto-rotate to be disabled? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Turning off auto-rotate"
	### Source -> https://askubuntu.com/questions/912916/add-lock-rotation-button-to-ubuntu-budgie
	gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true
fi

read -p "Do you want to disable Apport Crash Reporting? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Diasbling Apport crash ceporting"
	### Source -> https://computerobz.wordpress.com/2013/10/28/how-to-disable-stop-or-uninstall-apport-error-reporting-in-ubuntu/
	service apport stop
	cat /etc/default/apport | tail -1
	sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
	cat /etc/default/apport | tail -1
	apt-get purge apport
fi

### Clean-up ###

echo "Cleaning up"
apt autoremove -y
apt autoclean -y
