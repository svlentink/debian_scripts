#!/usr/bin/python3

from gpio import GPIOchip
from gpiod import line_request

SPECIAL_CHARS_IN_REPR_RELAY = False # Armbian doesnt display them

class Relay:
    def __init__(self, addr, metadata, is_powered: bool = False):
        self.addr = addr
        self.data = metadata
        self._is_powered = is_powered
        self.timer = None
        self.__gpio_line = None

        if self.get_addr()[0] == 'GPIO':
            #GPIO.setmode(GPIO.BOARD)
            #GPIO.setup(addr['pin'], GPIO.OUT, initial=(not engaged))
            self.__gpio_line = GPIOchip.get_line(addr['pin'])
            self.__gpio_line.request(consumer=self.data['label'], type=line_request.DIRECTION_OUTPUT)

    @property
    def is_powered(self):
        return self._is_powered

    @is_powered.setter
    def is_powered(self, new_value):
        self._is_powered = new_value
        if not new_value: # if state of relay is set to False
            self.timer = None

    def get_state(self):
        return (self.addr, self.data, self.is_powered)

    def is_scheduled_to_go_off(self):
        """
        We keep the metadata of the timer on the Relay
        but the actual scheduling of it needs to be done on the board level
        because we can only set the state of a whole row of relays,
        not just one at a time, so the timer is scheduled at the RelayBoard
        """
        return self.timer and self.timer.remaining

    def auto_off_sec(self):
        if 'auto_off_sec' in self.data and self.data['auto_off_sec'] > 0:
            return self.data['auto_off_sec']
        else:
            return False

    def set_gpio(self, val):
        self.is_powered = val
        return self.__gpio_line.set_value(not val)

    def get_addr(self):
        typ = self.addr['type'].upper()
        if typ == 'I2C':
            return (typ, (self.addr['bus'], self.addr['chip'], self.addr['data']), self.addr['id'] )
        if typ == 'GPIO':
            return (typ, self.addr['pin'])
        return (typ, 'UNKNOWN_TYPE')

    def timer_remaining_str(self):
        if self.is_scheduled_to_go_off():
            return f"seconds until turning off: {int(self.timer.remaining)}"
        return ""


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
    {self.timer_remaining_str()}
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
{lbl:^{max_length-5}} ⚡🧲⚟ ⌌○──COM  {COM}  {self.timer_remaining_str()}
{addr:<{max_length}}  ⌎○───NO  {NO}
"""
            else:
                result += f"""
{name:<{max_length}}   o  -NC  {NC}
{lbl:^{max_length-5}}   ~{'{'}  ,o--COM  {COM}  {self.timer_remaining_str()}
{addr:<{max_length}}  `o---NO  {NO}
"""
        else:
            if SPECIAL_CHARS_IN_REPR_RELAY:
                result += f"""
{name:<{max_length}}  ⌌○───NC  {NC}
{lbl:^{max_length-5}}   🧲  ⌎○──COM  {COM}  {self.timer_remaining_str()}
{addr:<{max_length}}   ○---NO  {NO}
"""
            else:
                result += f"""
{name:<{max_length}}  ,o---NC  {NC}
{lbl:^{max_length-5}}    {'{'}  `o--COM  {COM}  {self.timer_remaining_str()}
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

