#!/usr/bin/env python3

# MQTT to be inter operable with Home Assistant
# REST API for local debugging
# Unix sockets for separation
# ZeroMQ on top of unix sockets

|  [ Physical Button ] ---> [ C / Python Watcher ]                                 |
|                                  |                                                |
|                             (Unix Socket)                                         |
|                                  v                                                |
|                           [ Local Gateway Daemon ] ---> (MQTT / Network)

mqtt socket


import zmq
import pynng
from pynng import Rep0

def nng_listen()
    server = Rep0()
    server.listen("ipc:///var/run/myapp/nng.sock")

def zeroMQ_listen():
    ctx = zmq.Context()
    socket = ctx.socket(zmq.PULL)
    socket.connect("ipc:///run/myapp/gpio.sock")
    
    while True:
        event = socket.recv_json()
        print(event)

os.uname().nodename








┌──────────────────────── Host ────────────────────────┐
│                                                       │
│  GPIO hardware                                        │
│      │                                                │
│      ▼                                                │
│  gpio_button_watcher.py                               │
│      │                                                │
│      │ ZeroMQ PUSH                                    │
│      ▼                                                │
│  /run/myapp/gpio.sock                                 │
│                                                       │
└───────────────────────┬───────────────────────────────┘
                        │ Unix socket mounted
                        ▼
┌──────────────────────── Container ───────────────────┐
│                                                       │
│  message_broker.py                                    │
│      │                                                │
│      │ ZeroMQ PULL                                    │
│      ▼                                                │
│  MQTT client                                           │
│      │                                                │
└──────┼────────────────────────────────────────────────┘
       │
       │ MQTT
       ▼
┌───────────────────────┐
│ Home Assistant        │
│                       │
│ button/device/event   │
└───────────────────────┘

{
  "event": "button_pressed",
  "button": "/roomB/front_door",
  "timestamp": 1723200000
  "src": {
      "protocol": "REST/http"
      "host" : "roomB"
  }
}
prefix all with hostname
homeassistant/event/front_door


GPIO
  │
  ▼
Python watcher
  │
  │ ZeroMQ / Unix socket
  ▼
message_broker
  │
  │ MQTT
  ▼
Home Assistant



https://spec.openapis.org/oas/v3.2.0.html

                 ┌─────────────────────┐
                 │  Protobuf messages  │
                 └──────────┬──────────┘
                            │
                 ┌──────────▼──────────┐
                 │    ZeroMQ / NNG     │
                 └──────────┬──────────┘
                            │
                       ipc://...
                            │
       ┌────────────────────┼────────────────────┐
       ▼                    ▼                    ▼
   sensors.py          automation.py         ui.py

https://github.com/solo-io/protoc-gen-openapi





