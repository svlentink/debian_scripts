#!/usr/bin/env python3

# an alternative to https://www.home-assistant.io/integrations/binary_sensor/
# https://community.home-assistant.io/t/esp-home-simple-switch-button-wiring-and-code/859673/6
# https://community.home-assistant.io/t/pysical-pushbutton-on-gpio-to-shut-down-home-assistant/570622/4

import time
from gpio import GPIOchip
from gpiod import LINE_REQ_EV_BOTH_EDGES
from gpiod.line import Direction, Value
from gpiod.line import Direction, Edge, Bias
import gpiod
from datetime import timedelta
import yaml
from pathlib import Path
import requests
from dataclasses import dataclass

#If you're building a service that reacts to GPIO events, look for:

#Edge-triggered callbacks (when_pressed, add_event_detect, etc.)
#Async support with asyncio

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


class InputWatcher:
    def __init__(self, conf_path: str = '/etc/binary_sensors.yml', line_cfg = DEFAULT_LINE_CONFIG, chip='/dev/gpiochip0'):
        self._line_cfg = line_cfg
        self._chip = chip
        with open(conf_path, 'r') as fp:
            raw_config = yaml.safe_load(fp)
        self._sensors = self.__parse_conf(raw_config)
    

    def _on_event(self, pin: int, is_high: bool, read_on_init_instead_of_triggered: bool = False, bias = Bias.PULL_UP):
        if bias == Bias.PULL_UP: # button connected to ground
            # button engaged: DOWN because pulled to ground
            # button disengaged: HIGH because pulled up
            is_engaged = not is_high
        else: # bias == Bias.PULL_DOWN
            is_engaged = is_high

        self._run_actions(pin, is_engaged)

    def _run_actions(self, pin, is_engaged: bool):


    def _run_blocking(self):
        with gpiod.request_lines(self._chip, consumer="button-monitor", config=config_map) as request:
            binary_sensor_states = request.get_values()
            for i, pin in enumerate(gpio_pins):
                is_high = binary_sensor_states[i] == Value.ACTIVE # or Value.INACTIVE
                self._on_event(pin, is_high, True)
                
            while True:
                # Block until an event occurs on ANY of the requested lines
                for event in request.read_edge_events():
                    pin = event.line_offset
                    is_high = event.event_type == event.Type.RISING_EDGE # or FALLING_EDGE
                    self._on_event(pin, is_high)

        
    def __parse_conf(self, conf):
        if not 'gpio' in conf:
            raise Exception("config is missing gpio section")

        pins = conf['gpio']

        # Bundle the pins into a configuration mapping
        # Passing a tuple/list of pins as a key applies the settings to all of them
        self._listener_instructions = {
            tuple(pins.keys()): self._line_cfg
        }

        result = []
        for pin, sensor_data in pins.items():
            relay = Relay(pin, sensor_data)
            result.append(relay)

        return result

# Configure settings universally for all target lines
DEFAULT_LINE_CONFIG = gpiod.LineSettings(
    direction=Direction.INPUT,
    edge_detection=Edge.BOTH,                   # both press and release
    bias=Bias.PULL_UP,                          # button pin connected to GND
    debounce_period=timedelta(milliseconds=100) # Filter out button rattle
)

@dataclass
class BinarySensor:
    pin: int
    line_cfg: gpiod.LineSettings = DEFAULT_LINE_CONFIG
    __is_engaged: bool = False

    @property
    def is_engaged(self)
        return self.__is_engaged

    @is_engaged.setter
    def is_engaged(self, state: bool):
        if state == self.__is_engaged:
            return
        self.__is_engaged = state
        self.run_actions()

    def __str__(self):
        result = ''
        if bias == Bias.PULL_UP:
            prefix = ' GND'
        else:
            prefix = '3.3V'

        if self.is_engaged:
            result += '''
{prefix}---o__|__o---{self.pin} {}
'''
        else:
            result += '''
{prefix}---o  |  o---{self.pin} {}
         --'--
'''

    def run_actions():
        return



