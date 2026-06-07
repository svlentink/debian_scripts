#!/bin/bash

for i in /tmp/*.dts; do
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
