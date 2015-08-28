#!/bin/bash

if [ -z $(which xcalib) ]; then
	echo aborting, first run ubuntu_basics.sh
	exit
fi

function changeNrOfDesktops { #tested on lubuntu 15.04
	NR=$1
	if [ -z $1 ]; then
		NR=3
	fi
	sed -i 's/<number>2/<number>'$NR'/g' ~/.config/openbox/*.xml
}

function colorInvertKeybindLubuntu { # tested on lubuntu 15.04
	# xcalib -s 0 -i -a
	sed -i 's/<!-- Keybindings for window switching -->/<!--Keybindings for window switching--><keybind key="Super-N"><action name="Execute"><command>xcalib -a -i<\/command><\/action><\/keybind>/g' ~/.config/openbox/*.xml
	openbox --reconfigure
}

function invertColorsLXterminal { #tested on lubuntu 15.04
	sed -i 's/bgcolor=#000000000000/bgcolor=#ffffffffffff/g' ~/.config/lxterminal/*.conf
	sed -i 's/fgcolor=#aaaaaaaaaaaa/fgcolor=#333333333333/g' ~/.config/lxterminal/*.conf
}

function setSleepButton {#
	sed -i 's/<\/channel>/<property name="sleep-button-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="hibernate-button-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
}

function suspendOnLowPower {#
	sed -i 's/<\/channel>/<property name="critical-power-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="critical-power-level" type="uint" value="5"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
}

function sleepWhenLidCloses { #
	sed -i 's/<\/channel>/<property name="lid-action-on-battery" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="logind-handle-lid-switch" type="bool" value="true"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="lid-action-on-ac" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
}

function suspendOnLowPowerDOESNOTWORK {
	local DEST=~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	local GREP='<\/property>'
	local SED='<property name="critical-power-action" type="uint" value="1"\/><\/property>'
	sed -i 's/'$GREP'/'$SED'/g' $DEST
	local SED='<property name="critical-power-level" type="uint" value="5"\/><\/property>'
	sed -i 's/'$GREP'/'$SED'/g' $DEST
}


function INSTALLbasics { # tested on lubuntu 15.04
	sudo apt-get install shotwell -y
	sudo apt-get install htop
	sudo apt-get install vlc -y
	sudo apt-get install vim
	sudo apt-get install gnome-system-monitor -y
	sudo apt-get remove pidgin -y			# instant message
	sudo apt-get remove sylpheed -y		# mail client
}

function INSTALLoffice { # tested on lubuntu 15.04
	sudo apt-get remove abiword -y
	sudo apt-get install libreoffice -y
}

function runChromeOnBoot { # tested on lubuntu 15.04
	# http://dottech.org/118513/how-to-autostart-autorun-a-program-on-boot-in-ubuntu-guide/
	sudo ln -s /usr/share/applications/google-chrome.desktop ~/.config/autostart
}

function depricatedINSTALLarandr {
	echo DEPRICATED, from lubuntu 15.04 this is not needed anymore
#	sudo apt-get install arandr #for multiple screens
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
function addBatteryToTaskbar { # tested on lubuntu 15.04
	local dest=~/.config/lxpanel/Lubuntu/panels/panel

	echo Adding battery icon to task bar
	echo "Plugin {" >> $dest
	echo "type=batt" >> $dest
	echo "Config {" >> $dest
	echo "}" >> $dest
	echo "}" >> $dest
}
