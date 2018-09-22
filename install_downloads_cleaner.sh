#!/bin/sh
set -e

mkdir -p /usr/local/bin
cat <<'EOF'> /usr/local/bin/clean-downloads
#!/bin/sh
set -e
DIR=~/Downloads
RETENTION=3 # weeks
PREFIX=week_
WEEK=`date +%W`

for i in $DIR/*; do
  if [[ $i = *"$PREFIX"* ]]; then
    # backup directory with files
    if [[ $i = $PREFIX$(($WEEK-$RETENTION)) ]]; then
      mv $i /tmp/
    fi
  else
    CURRENTDIR=$DIR/$PREFIX$WEEK
    mkdir -p $CURRENTDIR
    mv "$i" $CURRENTDIR/
  fi
done
EOF

chmod +x /usr/local/bin/clean-downloads

cat <<'EOF'> /etc/systemd/system/clean-downloads.service
[Unit]
Description=Clean downloads
Wants=clean-downloads.timer

[Service]
Type=oneshot
Nice=19
ExecStart=/bin/bash /usr/local/bin/clean-downloads

[Install]
WantedBy=basic.target
EOF

cat <<'EOF'> /etc/systemd/system/clean-downloads.timer 
[Unit]
Description=Clean downloads job

[Timer]
OnCalendar=daily
Unit=clean-downloads.service

[Install]
WantedBy=basic.target
EOF

systemctl daemon-reload
systemctl enable clean-downloads.timer
systemctl start  clean-downloads.timer

