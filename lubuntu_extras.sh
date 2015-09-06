#!/bin/bash

function changeNrOfDesktops { #tested on lubuntu 15.04
	NR=$1
	if [ -z $1 ]; then
		NR=3
	fi
	sed -i 's/<number>2/<number>'$NR'/g' ~/.config/openbox/*.xml
}

function invertColorsLXterminal { #tested on lubuntu 15.04
	sed -i 's/bgcolor=#000000000000/bgcolor=#ffffffffffff/g' ~/.config/lxterminal/*.conf
	sed -i 's/fgcolor=#aaaaaaaaaaaa/fgcolor=#333333333333/g' ~/.config/lxterminal/*.conf
}

function INSTALLremoveJunk {
	sudo apt-get remove pidgin -y		# instant message
	sudo apt-get remove sylpheed -y		# mail client
	sudo apt-get remove firefox -y
}

function INSTALLoffice { # tested on lubuntu 15.04
	sudo apt-get remove abiword -y
	sudo apt-get install libreoffice -y
}

function runChromeOnBoot { # tested on lubuntu 15.04
	# http://dottech.org/118513/how-to-autostart-autorun-a-program-on-boot-in-ubuntu-guide/
	sudo ln -s /usr/share/applications/google-chrome.desktop ~/.config/autostart/google-chrome.desktop
}

function INSTALLsystemMonitors { # tested on lubuntu 15.04
	sudo apt-get install htop
	sudo apt-get install gnome-system-monitor -y
}
function addMonitorsToTaskbar { # tested on lubuntu 15.04
	local dest=~/.config/lxpanel/Lubuntu/panels/panel

	echo Adding system monitor to task bar
	echo "Plugin {" >> $dest
	echo "type=monitors" >> $dest
	echo "Config {" >> $dest
	echo "DisplayCPU=1" >> $dest
	echo "DisplayRAM=1" >> $dest
	echo "Action=gnome-system-monitor" >> $dest
	echo "CPUColor=#00FFFF" >> $dest
	echo "RAMColor=#FFFF00" >> $dest
	echo "}" >> $dest
	echo "}" >> $dest
}

function INSTALLbasics { # tested on lubuntu 15.04
	sudo apt-get install shotwell -y
	sudo apt-get install vlc -y
	sudo apt-get install vim
	INSTALLsystemMonitors
	INSTALLremoveJunk
}

function chromify { #turn pc to chromebook
	INSTALLremoveJunk
	runChromeOnBoot
	#TODO
	#remove garbage icon desktop
	#open doc, docx, xls, xlsx, pdf etc. in chrome
	#the following extension is needed to prevent chrome from downloading it, and instead opening it:
	#https://chrome.google.com/webstore/detail/office-editing-for-docs-s/gbkeegbaiigmenfmjfclcdgdpimamgkj
}


$@
