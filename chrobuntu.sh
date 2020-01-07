#!/bin/bash

function runFromUrl {
	wget --no-cache -O /tmp/tmpDownloaded.sh $1
	shift
	sudo chmod +x /tmp/tmpDownloaded.sh
	/tmp/tmpDownloaded.sh $@
}

runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/ubuntu_basics.sh
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/lubuntu_basics.sh
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/lubuntu_extras.sh chromify
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/geoloc.sh
