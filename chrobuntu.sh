#!/bin/bash

function runFromUrl {
	wget --no-cache -O /tmp/tmpDownloaded.sh $1
	sudo chmod +x /tmp/tmpDownloaded.sh
	sh /tmpDownloaded.sh $2 $3 $4 $5 $6 $7 $8 $9
}

runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/ubuntu_basics.sh
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/lubuntu_basics.sh
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/lubuntu_extras.sh chromify
runFromUrl https://raw.githubusercontent.com/svlentink/debian_scripts/master/geoloc.sh
