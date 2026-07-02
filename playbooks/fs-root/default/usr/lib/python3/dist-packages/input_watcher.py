#!/usr/bin/env python3

import time
from gpio import GPIOchip
from gpiod import LINE_REQ_EV_BOTH_EDGES
import yaml
from pathlib import Path


class Btnwatcher:

  def __init__(self, pins=pinout):
    self._pins = pins
    GPIO.setmode(GPIO.BCM)
    for boardi in pins:
      board = pins[boardi]
      for col in board['cols']:
        GPIO.setup(col, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
      for row in board['rows']:
        GPIO.setup(row, GPIO.OUT)
  
  def __iter__(self):
    return self

  def __next__(self):
    pins = self._pins
    cols = pins['L']['cols'] + pins['R']['cols']
    state = set()
    while True:
      something_pressed = False
      for rowi in range(2):
        on = pins['L']['rows'][rowi]
        off = pins['L']['rows'][rowi-1]
        GPIO.output(on,1)
        GPIO.output(off,0)
        on = pins['R']['rows'][rowi]
        off = pins['R']['rows'][rowi-1]
        GPIO.output(on,1)
        GPIO.output(off,0)
  
        sleep(0.02)
  
        for coli in range(len(cols)):
          pin = cols[coli]
          if GPIO.input(pin):
            pressed = (coli,  rowi)
            state.add(pressed)
            something_pressed = True
  
      if not something_pressed and state:
        return state
        state = set()


pin = 23 #which is PA14 on pinout
GPIO.setmode(GPIO.BOARD)
GPIO.setup(pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)

def door_open_recently_triggered(fn="/var/log/door-open-triggered.log"):
  with open(fn,"r") as f:
    filecontent = f.read()
  return datetime.datetime.now().isoformat()[:16] in filecontent

def door_is_open():
  return GPIO.input(pin) == GPIO.HIGH

while True:
    time.sleep(0.3)
    if door_is_open() and door_open_recently_triggered():
        os.system('capture-webcam')



line = GPIOchip.get_line(17)

line.request(
    consumer="monitor",
    type=LINE_REQ_EV_BOTH_EDGES
)

while True:
    event = line.event_wait(sec=10)
    if event:
        evt = line.event_read()
        print(evt)


#If you're building a service that reacts to GPIO events, look for:

#Edge-triggered callbacks (when_pressed, add_event_detect, etc.)
#Async support with asyncio

import gpiod
import requests

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




