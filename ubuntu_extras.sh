#!/bin/bash

function INTSTALLdropboxPPA { # tested on lubuntu 15.04
	 # http://www.ubuntuupdates.org/ppa/dropbox
	sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
	sudo sh -c 'echo "deb http://linux.dropbox.com/ubuntu/ utopic main" >> /etc/apt/sources.list.d/dropbox.list'
}
function INSTALLdropbox { # tested on lubuntu 15.04
	sudo apt-get install dropbox -y
	dropbox start -i
	echo 'file:///home/'$USER'/Dropbox' >> ~/.config/gtk-3.0/bookmarks
}

function INSTALLlighttablePPA { # tested on lubuntu 15.04
	sudo add-apt-repository ppa:dr-akulavich/lighttable
}
function INSTALLlighttable { # tested on lubuntu 15.04
	sudo apt-get install lighttable-installer
	sudo ln -s /opt/LightTable/LightTable /usr/local/bin/lighttable
	# in order for the light table settings to be applied, the IDE should not have been launched before
	# otherwise, you'll need to delete; rm ~/.config/LightTable
	local dest=/opt/LightTable/core/User/user.behaviors

	echo setting light theme for better use with color inversion
	sudo sed -i 's/default/solarized-light/g' $dest
	echo turning on line numbers
	sudo sed -i 's/no-wrap]/no-wrap ][:editor :lt.objs.editor\/line-numbers]/g' $dest
	echo setting workspace to open on start light table
	sudo sed -i 's/user_compiled.js"]/user_compiled.js" ][:app :lt.objs.sidebar.workspace\/workspace.open-on-start]/g' $dest
}
#sudo apt-get install hunspell-en-us
#[:app :lt.plugins.spelling/set-dictionary-location "/usr/share/hunspell"]
#[:editor.latex :lt.plugins.spelling/enable]
#[:editor.javascript :lt.plugins.spelling/enable]


function INSTALLgeany { #tested on lubuntu 15.04
	sudo apt-get install geany -y
	sudo apt-get install geany-plugins -y
	echo 'show_hidden_files=true' >> ~/.config/geany/plugins/treebrowser/*.conf
}

function INSTALLgit { # tested on lubuntu 15.04
	sudo apt-get install git -y
	#TODO question user for his/her email
	git config --global user.email 'svlentink@gmail.com'
	git config --global user.name 'svlentink'
}

function INSTALLchromium { # tested on lubuntu 15.04
	sudo apt-get install chromium-browser -y
}

function INSTALLjava { # default-jre
	sudo apt-get install icedtea-7-plugin openjdk-7-jre openjdk-7-jdk
}

function INSTALLmidori { # tested on lubuntu 15.04
	sudo apt-get install midori -y
}

function INSTALLpopcornTimePPA { #http://www.webupd8.org/2014/05/install-popcorn-time-in-ubuntu-or.html
	sudo add-apt-repository ppa:webupd8team/popcorntime
}
function INSTALLpopcornTime {
	sudo apt-get install popcorn-time
}

function INSTALLspotifyPPA {
	echo "deb http://repository.spotify.com stable non-free" | sudo tee --append /etc/apt/sources.list
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
	sudo apt-get update && sudo apt-get install spotify-client
	cd /tmp
	wget http://security.debian.org/debian-security/pool/updates/main/libg/libgcrypt11/libgcrypt11_1.5.0-5+deb7u3_amd64.deb
	sudo dpkg -i libgcrypt11_1.5.0-5+deb7u3_amd64.deb

}
function INSTALLspotify {
	sudo apt-get install spotify-client
	cd /tmp
	echo downloading a depricated libgcrypt for spotify, since spotify for debian is crap, as tested in apr 2015
	wget http://security.debian.org/debian-security/pool/updates/main/libg/libgcrypt11/libgcrypt11_1.5.0-5+deb7u3_amd64.deb

	read -p "Install libgcrypt11 [Y/n]?" yn
	case $yn in
		[Yy]* ) pkg -i libgcrypt11_1.5.0-5+deb7u3_amd64.deb;;
		* ) echo 'okay, skipping it';;
	esac
}

function INSTALLwidevineAndSilverlightPPA {
	apt-add-repository ppa:pipelight/stable
}

function INSTALLwidevineAndSilverlight {
	read -p "Silverlight runs on wine, are you sure [Y/n]?" yn
	case $yn in
		[Yy]* ) apt-get install pipelight-multi; pipelight-plugin --enable silverlight; pipelight-plugin --enable widevine;;
		* ) echo 'okay, skipping it';;
	esac
}


# the following needs an introduction
# When I was at work, I got a phone call;
# the gf of my housemate was on the phone with an indian
# who claimed to be cyber security and was forced to install teamviewer.
# Ofcourse this person thought that if there was a cyber crime,
# it needed to be on my laptop.
#
# This made me re-evaluate my security.
# Just like you hide cleaning materials from children,
# I now know that I need to threat people around me
# with a white list approach, not a black list!
# You never know who your housemate has for a sleep over ;)
function bootInTty { # tested on lubuntu 15.10
	# http://unix.stackexchange.com/questions/115482/how-to-change-the-default-tty-after-boot
	local tty=$1
	if [ -n "$tty" ]; then
		local tty=1
	fi
	if [ -z "$(grep chvt /etc/rc.local)" ]; then
		echo allready booting in tty, returning from bootInTty
		return
	fi
	echo Setting default booting in tty$tty
	sudo sed -i 's/exit/chvt\ '$tty'\nexit/g' /etc/rc.local
}
function setTtyMsg { # tested on lubuntu 15.10
	local msg=$1
	if [ -n "$msg" ]; then
		local msg="Don't even try, I will look for you, I will find you, and I will kill you!"
	fi
	echo $msg" \l" | sudo tee /etc/issue
}
