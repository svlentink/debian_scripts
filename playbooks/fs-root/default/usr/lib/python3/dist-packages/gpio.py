
# FIXME libgpiod
# Orange Pi → OPi.GPIO
# Radxa / ROCK → RPi.GPIO or gpiod
# Raspberry Pi → RPi.GPIO
# Generic Linux fallback → gpiod

def load_gpio():
    model = ""
    try:
        with open("/proc/device-tree/model") as f:
            model = f.read().lower()
    except:
        pass

    if "orange pi" in model:
        import OPi.GPIO as GPIO
        GPIO.setwarnings(False)
    elif "radxa" in model or "rock" in model:
        import RPi.GPIO as GPIO
    else:
        import gpiod as GPIO
        #raise RuntimeError(f"Unknown board: {model}")

    return GPIO


GPIO = load_gpio()
