#!/bin/bash
set -u

. /host.env

hostnamectl set-hostname "$HOSTNAME" || echo "$HOSTNAME" > /etc/hostname

# The first part of a MAC address is the vendor id
# therefor for the bridge we use the one from the primary ethernet port
# so the MAC address will be easier to trace to the right type of device
MAC_PREFIX="`cat /sys/class/net/e*0/address|cut -c 1-8`"

mkdir -p /etc/systemd/network/br0.network.d/

cat << EOF > /etc/systemd/network/br0.network.d/mac.conf
[Link]
MACAddress=$MAC_PREFIX:$MAC_POSTFIX
EOF

echo Reload the network which might have changed the MACAddress and thus the IP
systemctl daemon-reload && networkctl reload
