#!/bin/bash

if [ -z $(which xcalib) ]; then
	echo aborting, first run ubuntu_basics.sh
	exit
fi

function colorInvertKeybindLubuntu { # tested on lubuntu 15.04
	# xcalib -s 0 -i -a
	sed -i 's/<!-- Keybindings for window switching -->/<!--Keybindings for window switching--><keybind key="Super-N"><action name="Execute"><command>xcalib -a -i<\/command><\/action><\/keybind>/g' ~/.config/openbox/*.xml
	openbox --reconfigure
}

function setSleepButton {
	sed -i 's/<\/channel>/<property name="sleep-button-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="hibernate-button-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
}

function suspendOnLowPower {
	sed -i 's/<\/channel>/<property name="critical-power-action" type="uint" value="1"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
	sed -i 's/<\/channel>/<property name="critical-power-level" type="uint" value="5"\/>\n<\/channel>/g' ~/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
}

function sleepWhenLidCloses {
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

function depricatedINSTALLarandr {
	echo DEPRICATED, from lubuntu 15.04 this is not needed anymore
#	sudo apt-get install arandr #for multiple screens
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

colorInvertKeybindLubuntu
setSleepButton
suspendOnLowPower
sleepWhenLidCloses
addBatteryToTaskbar
