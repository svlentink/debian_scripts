#!/usr/bin/python3

import sys
from relay_board import RelayBoard

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

