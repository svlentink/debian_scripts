#!/bin/bash

function INSTALLubuntuCodecs { # tested on lubuntu 15.04
	# This provides codecs for media playback and more
	sudo apt-get install ubuntu-restricted-extras -y
	sudo apt-get install libavcodec-extra
}

function INSTALLcolorInvert {
	sudo apt-get install xcalib
}

function depricatedChangeSwappiness { # http://bernaerts.dyndns.org/linux/74-ubuntu/250-ubuntu-tweaks-ssd
	#sysctl -w vm.swappiness=10
	echo 'vm.swappiness = 1' | sudo tee --append /etc/sysctl.conf
}

function INSTALLflash { #almost depricated, who uses flash these days? (2015)
	sudo apt-get install flashplugin-installer
	sudo apt-get install pepperflashplugin-nonfree -y
	sudo update-pepperflashplugin-nonfree --install
}

function disableUbuntuErrorMessages { #tested on lubuntu 15.04
	echo 'enabled=0'| sudo tee /etc/default/apport
}

function updateAlias { # tested on lubuntu 15.04
	sudo echo "alias update='sudo apt update && sudo apt full-upgrade -y && if [ -n \"\$(which npm)\" ]; then sudo npm install -g npm && sudo npm update -g; fi && sudo apt-get autoremove -y && do-release-upgrade'" >> ~/.bashrc
}

function INSTALLpreload { # tested on lubuntu 15.04
	sudo apt-get install preload
}

function INSTALLgoogleChromePPA { # tested on lubuntu 15.04
	#https://www.google.com/linuxrepositories
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
}

function INSTALLgoogleChrome { # tested on lubuntu 15.04
	sudo apt-get install google-chrome-stable -y
}

#personal preferences
	updateAlias
	disableUbuntuErrorMessages
#PPAs
	INSTALLgoogleChromePPA
#adding PPAs
	sudo apt-get update
#installing
	INSTALLpreload
	INSTALLcolorInvert
	INSTALLgoogleChrome
	INSTALLflash
	INSTALLubuntuCodecs
