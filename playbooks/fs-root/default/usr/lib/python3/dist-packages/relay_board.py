#!/usr/bin/python3

import smbus2
#import smbus as smbus2
import yaml
from pathlib import Path
from trackabletimer import TrackableTimer
from single_relay import Relay 

class RelayBoard:
    def __init__(self, conf_path: str = "/etc/relay.yml", state_path: str = "/run/relay.yml"):
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

    def __repr__(self):
        return str(self)
    def __str__(self):
        result = ''
        for i, relay in enumerate(self.relays):
            result += str(i) + str(relay)
        return result
    def html(self):
        result = {}
        for r in self.relays:
            loc = r.data["location"] if "location" in r.data else '_'
            if loc not in result:
                result[loc] = f"<hr/>{loc}<br/>"
            result[loc] += r.html()
        return "<br/>".join(result.values())

    def get(self, name: str):
        if name.isdigit():
            return self.relays[int(name)]
        for relay in self.relays:
            if 'name' in relay.data and relay.data['name'] == name:
                return relay

    def set(self, name: str, is_powered: bool):
        if type(is_powered) == str:
            is_powered = int(is_powered)
        if type(is_powered) == int:
            is_powered = bool(is_powered)

        if name.lower() == "all":
            for relay in self.relays:
                 self.__set(relay, is_powered)
        else:
            relay = self.get(name)
            if not relay:
                return f"No relay with name: {name}"
            self.__set(relay, is_powered)

    def schedule_off_if_needed(self, relay: Relay):
        auto_off = relay.auto_off_sec()
        if not auto_off:
            return

        relay.timer = TrackableTimer(auto_off, self.__set, [relay, False])

    def __set(self, relay: Relay, is_powered: bool):
        relay_addr = relay.get_addr()
        relay_type = relay_addr[0]
        if relay_type == "GPIO":
            #pin = relay.get_addr()[1]
            #GPIO.output(pin, not relay.is_powered)
            relay.set_gpio(relay.is_powered)
        if relay_type == "I2C":
            relay.is_powered = is_powered
            neighbors = [ n for n in self.relays if n.close_neighbor(relay) ]
            data_val = 255 #int('0xff',16)
            neighbors.append(relay)
            for r in neighbors:
                data_id = r.get_addr()[2]
                data_val -= r.is_powered<<data_id
            relay_i2c_addr = relay_addr[1]
            bus_addr, chip_addr, data_addr = relay_i2c_addr
            if type(bus_addr) == str:
                bus_addr = int(bus_addr,16)
            if type(chip_addr) == str:
                chip_addr = int(chip_addr,16)
            if type(data_addr) == str:
                data_addr = int(data_addr,16)
            bus = smbus2.SMBus(bus_addr)
            print(f"executing: i2cset {bus_addr} {chip_addr} {data_addr} {data_val}")
            bus.write_byte_data(chip_addr, data_addr, data_val)
        
        if is_powered:
            self.schedule_off_if_needed(relay)
        self.save_state()

