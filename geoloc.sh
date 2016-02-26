#!/bin/bash
SCRIPTLOC=/usr/bin/geolocation.sh


#TODO
#add interval file in directory and make */2 == * inside cron (not implemented, currently fixed time; ease over configurable)
#add file for location service (currently fixed)
# http://ipinfo.io/json
# http://ip-api.com/json
# https://freegeoip.net/json/ (currently used)


#create script
echo '#!/bin/bash' | sudo tee $SCRIPTLOC
echo 'DIR=$HOME/.local/share/geolocation' | sudo tee --append $SCRIPTLOC

echo -e '\nfunction getLocation {' | sudo tee --append $SCRIPTLOC
	echo -e '\tif [ -z "$(cat $DIR/.currentLocation)" ]; then' | sudo tee --append $SCRIPTLOC
		echo -e '\t\t/bin/echo No last location found' | sudo tee --append $SCRIPTLOC
	echo -e '\telse' | sudo tee --append $SCRIPTLOC
		echo -e '\t\t/bin/cp $DIR/.currentLocation $DIR/.oldLocation' | sudo tee --append $SCRIPTLOC
	echo -e '\tfi' | sudo tee --append $SCRIPTLOC

	echo -e '\n\t/usr/bin/wget --no-cache -O $DIR/.currentLocation https://freegeoip.net/json/' | sudo tee --append $SCRIPTLOC
	echo -e '\t/bin/echo $(/bin/date ---iso-8601=seconds) > $DIR/.lastUpdateTime' | sudo tee --append $SCRIPTLOC
	echo -e '\tif [ -z "$(cat $DIR/.currentLocation)" ]; then' | sudo tee --append $SCRIPTLOC
		echo -e '\t\texit' | sudo tee --append $SCRIPTLOC
	echo -e '\tfi' | sudo tee --append $SCRIPTLOC
	echo -e '\n\tif [ -z "$(/usr/bin/diff $DIR/.currentLocation $DIR/.oldLocation)" ]; then' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/echo Still at the same location' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/rm $DIR/.oldLocation' | sudo tee --append $SCRIPTLOC
	echo -e '\telse' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/echo Location changed' | sudo tee --append $SCRIPTLOC
	echo -e '\t\tARRIVED=$(/bin/cat $DIR/.arrivedAtTime)' | sudo tee --append $SCRIPTLOC
	echo -e '\t\tDEPARTURE=$(/bin/cat $DIR/.lastUpdateTime)' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/sed -i "s|}|,\"arrival\":\"$ARRIVED\"}|g" $DIR/.oldLocation' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/sed -i "s|}|,\"departure\":\"$DEPARTURE\"}|g" $DIR/.oldLocation' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/echo $(/bin/cat $DIR/.oldLocation) >> $DIR/log' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/rm $DIR/.oldLocation' | sudo tee --append $SCRIPTLOC
	echo -e '\t\t/bin/echo $(/bin/date ---iso-8601=seconds) > $DIR/.arrivedAtTime' | sudo tee --append $SCRIPTLOC
	echo -e '\tfi' | sudo tee --append $SCRIPTLOC
echo -e '}\n' | sudo tee --append $SCRIPTLOC

echo 'function createDir {' | sudo tee --append $SCRIPTLOC
	echo -e '\t/bin/mkdir $DIR' | sudo tee --append $SCRIPTLOC
	echo -e '\t/bin/echo $(/bin/date ---iso-8601=seconds) > $DIR/.arrivedAtTime' | sudo tee --append $SCRIPTLOC
echo -e '}\n' | sudo tee --append $SCRIPTLOC

echo 'if [ -d $DIR ]; then' | sudo tee --append $SCRIPTLOC
echo -e '\tgetLocation' | sudo tee --append $SCRIPTLOC
echo 'else' | sudo tee --append $SCRIPTLOC
echo -e '\tcreateDir' | sudo tee --append $SCRIPTLOC
echo -e '\tgetLocation' | sudo tee --append $SCRIPTLOC
echo 'fi' | sudo tee --append $SCRIPTLOC
sudo chmod +x $SCRIPTLOC

#creating cron job
if [ -z "$(sudo grep geo /var/spool/cron/crontabs/$USER)" ]; then
  echo '*/5 * * * * /bin/bash /usr/bin/geolocation.sh > /dev/null 2>&1' | sudo tee --append /var/spool/cron/crontabs/$USER
	sudo chmod 600 /var/spool/cron/crontabs/$USER
fi
