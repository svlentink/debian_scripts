#!/usr/bin/env python3

import time
from gpio import GPIOchip
from gpiod import LINE_REQ_EV_BOTH_EDGES
from gpiod.line import Direction, Value
import gpiod
from gpiod.line import Direction, Edge, Bias
from datetime import timedelta
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


# Define the chip path and the list of pin offsets you want to read
CHIP_PATH = "/dev/gpiochip4"  # Change to your chip (e.g., /dev/gpiochip0)
BUTTON_PINS = [5, 6, 13]      # The GPIO line numbers

# Configure settings universally for all target lines
DEFAULT_LINE_CONFIG = gpiod.LineSettings(
    direction=Direction.INPUT,
    edge_detection=Edge.BOTH,                   # both press and release
    bias=Bias.PULL_UP,                          # button pin connected to GND
    debounce_period=timedelta(milliseconds=100) # Filter out button rattle
)

# Bundle the pins into a configuration mapping
# Passing a tuple/list of pins as a key applies the settings to all of them
config_map = {
    tuple(BUTTON_PINS): line_cfg
}

class InputWatcher:
    def __init__(self, conf_path: str = '/etc/binary_sensors.yml', line_cfg = DEFAULT_LINE_CONFIG):
        self._sensors = self.load_conf
 

    def _on_event(self, pin: int, is_high: bool, read_on_init_instead_of_triggered: bool = False, bias = Bias.PULL_UP):
        if bias == Bias.PULL_UP: # button connected to ground
            # button engaged: DOWN because pulled to ground
            # button disengaged: HIGH because pulled up
            is_engaged = not is_high
        else: # bias == Bias.PULL_DOWN
            is_engaged = is_high


    def _run_blocking(self):
        with gpiod.request_lines(CHIP_PATH, consumer="button-monitor", config=config_map) as request:
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
        

class RelayBoard:
    def __init__(self, conf_path: str = "/etc/input_switches.yml", state_path: str = "/run/relay.yml"):
        self.state_path = state_path
        if Path(self.state_path).is_file() and False: # disabled because since we introduced Timer, this cannot be written to disk
            with open(self.state_path, 'r') as fp:
                self.relays = [Relay(*i) for i in yaml.safe_load(fp)]
        else: # we only reload the config after a reboot when state_path stored in /run
            with open(conf_path, 'r') as fp:
                raw_config = yaml.safe_load(fp)
            self.relays = self.__parse_conf(raw_config)
    
    def save_state(self):
        states = [list(r.get_state()) for r in self.relays]
        with open(self.state_path, 'w') as fp:
            yaml.dump(states, fp, default_flow_style=False)

    def __parse_conf(self, conf):
        result = []
        if 'gpio' in conf:
            for pin, relay_data in conf['gpio'].items():
                addr = {
                    'type': 'GPIO',
                    'pin': pin,
                }
                relay = Relay(addr, relay_data)
                result.append(relay)

        if 'i2c' in conf:
            for i2cbus, bus in conf['i2c'].items():
                for chip_addr, chip in bus.items():
                    for data_addr, data_list, in chip.items():
                        for relay_id, relay_data in enumerate(data_list):
                            addr = {
                                'type': 'I2C',
                                'bus': i2cbus,
                                'chip': chip_addr,
                                'data': data_addr,
                                'id': relay_id,
                            }
                            relay = Relay(addr, relay_data)
                            result.append(relay)
        return result

