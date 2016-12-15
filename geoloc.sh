#!/bin/bash
SCRIPTLOC=/usr/bin/geolocation.sh


#TODO
#add interval file in directory and make */2 == * inside cron (not implemented, currently fixed time; ease over configurable)
#add file for location service (currently fixed)
# http://ipinfo.io/json
# http://ip-api.com/json
# http://ifconfig.co/json
# https://freegeoip.net/json/ (currently used)


#create script
cat <<'EOF' > $SCRIPTLOC
#!/bin/bash
DIR=$HOME/.local/share/geolocation

function getLocation {
	if [ -z "$(cat $DIR/currentLocation)" ]; then
		/bin/echo No last location found
	else
		/bin/cp $DIR/currentLocation $DIR/oldLocation
	fi

	/usr/bin/wget --no-cache -O $DIR/currentLocation https://freegeoip.net/json/
	/bin/echo $(/bin/date -R) > $DIR/lastUpdateTime
	if [ -z "$(cat $DIR/currentLocation)" ]; then
		exit
	fi

	if [ -z "$(/usr/bin/diff $DIR/currentLocation $DIR/oldLocation)" ]; then
		/bin/echo Still at the same location
		/bin/rm $DIR/oldLocation
	else
		/bin/echo Location changed
		ARRIVED=$(/bin/cat $DIR/arrivedAtTime)
		DEPARTURE=$(/bin/cat $DIR/lastUpdateTime)
		/bin/sed -i "s|}|,\"arrival\":\"$ARRIVED\"}|g" $DIR/oldLocation
		/bin/sed -i "s|}|,\"departure\":\"$DEPARTURE\"}|g" $DIR/oldLocation
		/bin/echo $(/bin/cat $DIR/oldLocation) >> $DIR/log
		/bin/rm $DIR/oldLocation
		/bin/echo $(/bin/date -R) > $DIR/arrivedAtTime
	fi
}

function createDir {
	/bin/mkdir $DIR
	/bin/echo $(/bin/date -R) > $DIR/arrivedAtTime
}

if [ -d $DIR ]; then
	getLocation
else
	createDir
	getLocation
fi

EOF
sudo chmod +x $SCRIPTLOC

#creating cron job
if [ -z "$(sudo grep geo /var/spool/cron/crontabs/$USER)" ]; then
  echo '*/5 * * * * /bin/bash /usr/bin/geolocation.sh > /dev/null 2>&1' | sudo tee --append /var/spool/cron/crontabs/$USER
	sudo chmod 600 /var/spool/cron/crontabs/$USER
fi
