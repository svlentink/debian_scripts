
# FIXME libgpiod
# Orange Pi → OPi.GPIO
# Radxa / ROCK → RPi.GPIO or gpiod
# Raspberry Pi → RPi.GPIO
# Generic Linux fallback → gpiod

from  gpiod import Chip


def load_gpio():
    model = "gpiochip0"
    try:
        with open("/proc/device-tree/model") as f:
            model = f.read().lower()
    except:
        pass

# RPi.GPIO / OPi.GPIO: Use pin-numbering schemes (BOARD or BCM) and treat pins as global, individual entities.
# gpiod: Organizes pins by chips (e.g., gpiochip0) and lines (the hardware offset on that chip).
#    if "orange pi" in model:
#        import OPi.GPIO as GPIO
#        GPIO.setwarnings(False)
#    elif "radxa" in model or "rock" in model:
#        import RPi.GPIO as GPIO
#    else:
#        import gpiod as GPIO
#        #raise RuntimeError(f"Unknown board: {model}")

    
    return Chip(model)


GPIOchip = load_gpio()

