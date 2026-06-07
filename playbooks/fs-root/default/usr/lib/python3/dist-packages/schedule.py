# FIXME
# something like below

import sched
import time
from datetime import datetime

scheduler = sched.scheduler(time.time, time.sleep)

def run_at_iso(iso_str, action):
    target_dt = datetime.fromisoformat(iso_str)
    target_ts = target_dt.timestamp() # Converts to Unix float
    
    # enterabs uses an absolute time (Unix timestamp)
    scheduler.enterabs(target_ts, 1, action)
    print(f"Queued for {iso_str}")

run_at_iso("2026-04-23T16:00:00", my_task)
run_at_iso("2026-04-23T17:30:00", my_task)

# This blocks the script and waits for the events
scheduler.run()




import schedule
import time
from datetime import datetime, timedelta

def my_function():
    print("Task started.")
    return schedule.CancelJob # Runs only once

# Calculate the exact time 2 hours from now
run_time = (datetime.now() + timedelta(seconds=7200)).strftime("%H:%M:%S")

schedule.every().day.at(run_time).do(my_function)

while True:
    schedule.run_pending()
    time.sleep(1)


# we intentionally went for schedule and not APSchedule,
# since the later would persist the state,
# but at the expense of more writes to sd card
# we could use an external DB, but his would make it less reliable
