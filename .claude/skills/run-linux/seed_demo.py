"""Seeds a fresh database with two phased plans, for looking at plan screens.

Plan 1, "Strength year", is running on an 8-day microcycle (two or three
workouts on a training day, rest days between). Its log is simulated as if
every day had been trained on the day it was up, starting 50 days ago, so
Capacity is done and Basic strength is under way today, with today's day
still to train. Plan 2, "Next block", is stopped on a 7-day cycle and has
never run.
"""
import datetime as dt, sqlite3, sys

db = sqlite3.connect(sys.argv[1])
x = db.execute
if x('select count(*) from workouts').fetchone()[0]:
    sys.exit('database already has workouts; not seeding')

names = ['Climbing', 'Bench press', 'Shoulder press + mobility', 'Mobility',
         'Bulgarian split squats', 'Fingerboard']
for name in names:
    x('insert into workouts(name) values(?)', (name,))
W = {n: i + 1 for i, n in enumerate(names)}

# day → workouts; missing days rest.
STRENGTH = {
    1: ['Climbing', 'Bench press', 'Shoulder press + mobility'],
    2: ['Mobility', 'Bulgarian split squats'],
    4: ['Climbing', 'Fingerboard'],
    5: ['Bench press', 'Mobility'],
    7: ['Climbing'],
}
MAX = {
    1: ['Fingerboard', 'Bench press'],
    3: ['Climbing', 'Bulgarian split squats'],
    6: ['Fingerboard'],
}

def plan(pid, name, active, cycle_days, phases):
    x('insert into plans(id, name, active, cycle_days) values(?, ?, ?, ?)',
      (pid, name, active, cycle_days))
    for order, (phase_id, pname, cycles, every, days) in enumerate(phases):
        x('insert into plan_phases(id, plan_id, sort_order, name, length_passes,'
          ' deload_every) values(?, ?, ?, ?, ?, ?)',
          (phase_id, pid, order, pname, cycles, every))
        i = 0
        for day, workouts in sorted(days.items()):
            for w in workouts:
                x('insert into phase_sessions(phase_id, workout_id, day,'
                  ' sort_order) values(?, ?, ?, ?)', (phase_id, W[w], day, i))
                i += 1

plan(1, 'Strength year', 1, 8, [
    (1, 'Capacity', 4, 4, STRENGTH),
    (2, 'Basic strength', 6, 3, STRENGTH),
    (3, 'Max strength', 4, 2, MAX),
    (4, 'Peak', 2, None, MAX),
])
plan(2, 'Next block', 0, 7, [
    (5, 'Hypertrophy', 6, 3, {1: ['Bench press', 'Bulgarian split squats'],
                              3: ['Climbing'], 5: ['Shoulder press + mobility']}),
    (6, 'Power', 4, None, {1: ['Fingerboard'], 4: ['Climbing']}),
])

ts = 0
def event(phase, kind, day_str, workout=None, pass_=None, day=None, closes=0):
    """kind: 0 done, 1 skip, 2 deload, 3 advance."""
    global ts
    ts += 1
    x('insert into plan_events(plan_id, phase_id, workout_id, pass, day,'
      ' closes_day, date_str, timestamp, kind) values(1, ?, ?, ?, ?, ?, ?, ?, ?)',
      (phase, workout, pass_, day, closes, day_str, ts, kind))

# Every day trained on the day it is up: a training day's workouts that
# date, a rest day just passing. Today's day is left to train.
today = dt.date.today()
date = today - dt.timedelta(days=50)
phase, cycles, cycle_no, day = 1, 4, 1, 1
while date < today:
    workouts = STRENGTH.get(day, [])
    for i, w in enumerate(workouts):
        event(phase, 0, date.isoformat(), W[w], cycle_no, day,
              int(i == len(workouts) - 1))
    day += 1
    if day > 8:
        day, cycle_no = 1, cycle_no + 1
        if phase == 1 and cycle_no > cycles:
            event(1, 3, date.isoformat())
            phase, cycle_no = 2, 1
    date += dt.timedelta(days=1)

db.commit()
print('seeded', sys.argv[1])
