
import time
from threading import Timer

class TrackableTimer:
    def __init__(self, interval, function, args=None, kwargs=None):
        '''t = TrackableTimer(2,print,[22,33])
        '''
        self.interval = interval
        self.timer = Timer(interval, function, args, kwargs)
        self.start_time = time.monotonic() # time.time()
        self.timer.start()

    def cancel(self):
        if self.timer.is_alive():
            self.timer.cancel()

    @property
    def remaining(self):
        if ! self.timer.is_alive():
            return 0
        # If remaining is negative, the timer has already fired/expired
        return max(0, self.interval - (time.monotonic() - self.start_time))

    def __del__(self):
        '''This allows unsetting the variable that holds the timer,
           which now will automatically cancel it as well
        '''
        if hasattr(self, 'timer') and self.timer:
            self.timer.cancel()

