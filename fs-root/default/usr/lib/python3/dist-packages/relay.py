#!/usr/bin/python3
# this file should be in /usr/local/bin

import smbus2
#import smbus as smbus2
from gpio import GPIO
import yaml
from pathlib import Path
import sys
from threading import Timer

SPECIAL_CHARS_IN_REPR_RELAY = False # Armbian doesnt display them

class Relay:
    def __init__(self, addr, metadata, is_powered: bool = False):
        self.addr = addr
        self.data = metadata
        self.is_powered = is_powered
        self.timer = None

        if self.get_addr()[0] == 'GPIO':
            GPIO.setmode(GPIO.BOARD)
            GPIO.setup(addr['pin'], GPIO.OUT, initial=(not engaged))

    def get_state(self):
        return (self.addr, self.data, self.is_powered)

    def is_scheduled_to_go_off(self):
        """
        We keep the metadata of the timer on the Relay
        but the actual scheduling of it needs to be done on the board level
        because we can only set the state of a whole row of relays,
        not just one at a time, so the timer is scheduled at the RelayBoard
        """
        return self.timer and self.timer.is_alive()

    def auto_off_sec(self):
        if 'auto_off_sec' in self.data and self.data['auto_off_sec'] > 0:
            return self.data['auto_off_sec']
        else:
            return False

    def get_addr(self):
        typ = self.addr['type'].upper()
        if typ == 'I2C':
            return (typ, (self.addr['bus'], self.addr['chip'], self.addr['data']), self.addr['id'] )
        if typ == 'GPIO':
            return (typ, self.addr['pin'])
        return (typ, 'UNKNOWN_TYPE')

    def html(self):
        if not 'name' in self.data or len(self.data['name']) < 2:
            return ""
        name = self.data['name']
        clr = 'palegreen' if self.is_powered else 'lightpink'
        return f"""
<fieldset style='background-color:{clr};'>
    <legend>{name}</legend>
    <a href='/{name}/0'> OFF </a>
    &#9211;
    <a href='/{name}/1'> ON </a>
</fieldset>
"""

    def __repr__(self):
        return str(self)
    def __str__(self):
        max_length = 32
        NC = self.data['NC'] if 'NC' in self.data else ''
        NO = self.data['NO'] if 'NO' in self.data else ''
        COM = self.data['COM'] if 'COM' in self.data else ''
        lbl = self.data['label'][:max_length-5] if 'label' in self.data else 'LABEL'
        name = self.data['name'][:max_length] if 'name' in self.data else 'NO_NAME_PROVIDED'
        addr = str(self.get_addr())[:max_length]

        result = "_" * 43
        if self.is_powered:
            if SPECIAL_CHARS_IN_REPR_RELAY:
                result += f"""
{name:<{max_length}}   ○---NC  {NC}
{lbl:^{max_length-5}} ⚡🧲⚟ ⌌○──COM  {COM}
{addr:<{max_length}}  ⌎○───NO  {NO}
"""
            else:
                result += f"""
{name:<{max_length}}   o  -NC  {NC}
{lbl:^{max_length-5}}   ~{'{'}  ,o--COM  {COM}
{addr:<{max_length}}  `o---NO  {NO}
"""
        else:
            if SPECIAL_CHARS_IN_REPR_RELAY:
                result += f"""
{name:<{max_length}}  ⌌○───NC  {NC}
{lbl:^{max_length-5}}   🧲  ⌎○──COM  {COM}
{addr:<{max_length}}   ○---NO  {NO}
"""
            else:
                result += f"""
{name:<{max_length}}  ,o---NC  {NC}
{lbl:^{max_length-5}}    {'{'}  `o--COM  {COM}
{addr:<{max_length}}   o  -NO  {NO}
"""
        return result

    def close_neighbor(self, relay):
        ''' I2C module boards work with data_addresses that require you
        to set 8 module their state at once.
        This get_addr let's us determine if a relay is sharing their address (but not id)
        with other relays.
        '''
        if self.get_addr() == relay.get_addr():
            return False # comparison with self
        return self.get_addr()[:2] == relay.get_addr()[:2]

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

        relay.timer = Timer(auto_off, self.__set, [relay, False])
        relay.timer.start()

    def __set(self, relay: Relay, is_powered: bool):
        relay.is_powered = is_powered
        relay_addr = relay.get_addr()
        relay_type = relay_addr[0]
        if relay_type == "GPIO":
            pin = relay.get_addr()[1]
            GPIO.output(pin, not relay.is_powered)
        if relay_type == "I2C":
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
            bus.write_byte_data(chip_addr, data_addr, data_val)
        
        if is_powered:
            self.schedule_off_if_needed(relay)
        self.save_state()


if __name__ == "__main__":
    rb = RelayBoard()

    if len(sys.argv) == 3:
        name = sys.argv[1]
        is_powered = sys.argv[2]
        rb.set(name, is_powered)
        print('OK')
    else:
        print(rb)
        print(f"USAGE: {sys.argv[0]} under_desk_heater 1")

