#!/usr/bin/env python3

import time
from gpio import GPIOchip
from gpiod import LINE_REQ_EV_BOTH_EDGES
import yaml
from pathlib import Path
import gpiod
import requests


#If you're building a service that reacts to GPIO events, look for:

#Edge-triggered callbacks (when_pressed, add_event_detect, etc.)
#Async support with asyncio

CHIP = "/dev/gpiochip0"
LINE = 17

with gpiod.request_lines(
    CHIP,
    consumer="gpio-monitor",
    config={
        LINE: gpiod.LineSettings(
            edge_detection=gpiod.line.Edge.BOTH
        )
    },
) as req:

    while True:
        time.sleep(0.3)
        if req.wait_edge_events(timeout=1):
            events = req.read_edge_events()

            for event in events:
                requests.post(
                    "https://example.com/event",
                    json={
                        "gpio": LINE,
                        "type": event.event_type.name,
                    },
                    timeout=5,
                )

if state = previous_state:
    continue
if (time.monotonic() - 1)  < previous_statechange_time: # button rapidly switching
    continue




