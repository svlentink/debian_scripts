#!/bin/bash

# The following are expected to be set in host.env
HOSTNAME=fixme-hostname
MAC_POSTFIX="01:02:0a" # e.g. first floor, second room, device A
. /host.env

hostnamectl set-hostname "$HOSTNAME"

# The first part of a MAC address is the vendor id
# therefor for the bridge we use the one from the primary ethernet port
# so the MAC address will be easier to trace to the right type of device
MAC_PREFIX="`cat /sys/class/net/e*0/address|cut -c 1-8`"

if [[ -z "`grep MACAddress /etc/systemd/network/br0.netdev`" ]]; then
    echo "MACAddress=$MAC_PREFIX:$MAC_POSTFIX" >> /etc/systemd/network/br0.netdev
fi
