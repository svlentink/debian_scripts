# debian_scripts

##Chrobuntu
Turn a freshly installed Lubuntu laptop into a chromebook by running the following in terminal:
<br/>
`wget --no-cache -O /tmp/chromebk.sh \` <br/>
&nbsp;&nbsp; `https://raw.githubusercontent.com/svlentink/debian_scripts/master/chrobuntu.sh && \` <br/>
&nbsp;&nbsp; `sudo chmod +x /tmp/chromebk.sh && \` <br/>
&nbsp;&nbsp; `/tmp/chromebk.sh` <br/>

Or just copy the next line (same code, without format):
`wget --no-cache -O /tmp/chromebk.sh https://raw.githubusercontent.com/svlentink/debian_scripts/master/chrobuntu.sh && sudo chmod +x /tmp/chromebk.sh && /tmp/chromebk.sh`

## geoloc
This script enables the logging of the location of the machine.
I use this on my laptop, to keep track of where it was.
It can also be used for tracking your loved one (no, I know, your gf does not use debian),
or your own machine (ssh, see log, catch thief).

## mailer
This script enables the spoofing of an email address..
but does not work out of the box (to avoid spammers).
This script does not work everywhere, e.g. my current location (UvA),
blocks email traffic (like a public place should).
