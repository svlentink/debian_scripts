#!/bin/bash

. /host.env
OUT_PATH=/run/netstats/
mkdir -p $OUT_PATH

nmap \
    -oG $OUT_PATH/nmap.txt \
    -sn "$LOCALNET_PREFIX.0/24"

sleep 1

> $OUT_PATH/ping_response.txt
for i in {1..254}; do
    ( \
        ping -c 1 -W 1 $LOCALNET_PREFIX.$i > /dev/null \
        && echo $LOCALNET_PREFIX.$i \
        >> $OUT_PATH/ping_response.txt \
    ) & true;
done

sleep 1

> $OUT_PATH/neighbors.txt
ip neighbor \
    | sort \
    | uniq \
    | grep -v FAILED \
    | awk '{print $1}' \
    >> $OUT_PATH/neighbors.txt

#find /run/netstats/*

# FIXME
# https://github.com/dkran/nmap2json
