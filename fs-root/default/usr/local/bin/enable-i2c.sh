#!/bin/bash

for i in /home/radxa/*.dts; do
    dtc \
        -@ \
        -I dts \
        -O dtb \
        -o $i.dtbo \
        $i
done

echo "now install the overlays"
sleep 2
rsetup
