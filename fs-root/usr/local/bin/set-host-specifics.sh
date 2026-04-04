#!/bin/bash
set -ue

. /host.env

# The first part of a MAC address is the vendor id
# therefor for the bridge we use the one from the primary ethernet port
# so the MAC address will be easier to trace to the right type of device
MAC_PREFIX="`cat /sys/class/net/e*0/address|cut -c 1-8`"

#if [[ -z "`grep MACAddress /etc/systemd/network/br0.netdev`" ]]; then
mkdir -p /etc/systemd/network/br0.netdev.d/

cat << EOF > /etc/systemd/network/br0.netdev.d/mac.conf
[NetDev]
MACAddress=$MAC_PREFIX:$MAC_POSTFIX
EOF

hostnamectl set-hostname "$HOSTNAME"
