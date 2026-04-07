#!/bin/bash

NET_PREFIX=192.168.1
OUT_PATH=/run/netstats/
mkdir -p $OUT_PATH

nmap \
    -oG $OUT_PATH/nmap.txt \
    -sn "$NET_PREFIX.0/24"

sleep 1

> $OUT_PATH/ping_response.txt
for i in {1..254}; do
    ( \
        ping -c 1 -W 1 $NET_PREFIX.$i > /dev/null \
        && echo $NET_PREFIX.$i \
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
    > $OUT_PATH/neighbors.txt

#find /run/netstats/*
