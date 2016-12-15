# debian_scripts

##Chrobuntu
Turn a freshly installed Lubuntu laptop into a chromebook by running the following in terminal:
```
wget --no-cache -O /tmp/chromebk.sh \
  https://raw.githubusercontent.com/svlentink/debian_scripts/master/chrobuntu.sh && \
  sudo chmod +x /tmp/chromebk.sh && \
  /tmp/chromebk.sh
```

## geoloc
This script enables the logging of the location of the machine.
I use this on my laptop, to keep track of where it was.
It can also be used for tracking your loved one (no, I know, your gf does not use debian),
or your own machine (ssh, see log, catch thief).

