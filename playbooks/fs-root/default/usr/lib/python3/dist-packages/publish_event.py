#!/usr/bin/env python3

# Python classes like Relay and Button use this to publish (fire an event)

import zmq
import pynng
from pynng import Req0
from datetime import datetime, timezone

def pub():
    timestamp = datetime.now(timezone.utc).isoformat(timespec='seconds')


def nng_pub():
    client = Req0()
    client.dial("ipc:///var/run/myapp/nng.sock")

def zeroMQ_pub():
    ctx = zmq.Context()
    socket = ctx.socket(zmq.PUSH)
    socket.bind("ipc:///run/myapp/gpio.sock")
    
    socket.send_json({
        "event": "button_pressed",
        "button": "door"
    })

# we need to incorparate public/private key
# presign a scheduled action


