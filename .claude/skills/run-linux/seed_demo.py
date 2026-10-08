"""Seeds a fresh database with two phased plans, for looking at plan screens.

Plan 1, "Strength year", is running: Capacity done, Basic strength in week 7
of 10 at a session every three days (dated so that "today" is 2026-10-08;
other days shift the pace), then Max strength and Peak. Plan 2, "Next
block", is stopped and has never run.
"""
import datetime as dt, sqlite3, sys

db = sqlite3.connect(sys.argv[1])
x = db.execute
if x('select count(*) from workouts').fetchone()[0]:
    sys.exit('database already has workouts; not seeding')

for name in ['Lower A', 'Upper B', 'Pull C', 'Max lower', 'Max upper', 'Power']:
    x('insert into workouts(name) values(?)', (name,))

def plan(pid, name, active, phases):
    x('insert into plans(id, name, active) values(?, ?, ?)', (pid, name, active))
    for order, (phase_id, pname, weeks, every, rotation) in enumerate(phases):
        x('insert into plan_phases(id, plan_id, sort_order, name, length_passes,'
          ' deload_every) values(?, ?, ?, ?, ?, ?)',
          (phase_id, pid, order, pname, weeks, every))
        for i, w in enumerate(rotation):
            x('insert into phase_sessions(phase_id, workout_id, sort_order)'
              ' values(?, ?, ?)', (phase_id, w, i))

plan(1, 'Strength year', 1, [
    (1, 'Capacity', 8, 4, [1, 2, 3]),
    (2, 'Basic strength', 10, 4, [4, 5]),
    (3, 'Max strength', 6, 3, [6, 1]),
    (4, 'Peak', 3, None, [6]),
])
plan(2, 'Next block', 0, [
    (5, 'Hypertrophy', 6, 3, [1, 2]),
    (6, 'Power', 4, None, [6, 4, 5]),
])

ts = 0
def event(phase, kind, day, workout=None, pass_=None, closes=0):
    """kind: 0 done, 1 skip, 2 deload, 3 advance."""
    global ts
    ts += 1
    x('insert into plan_events(plan_id, phase_id, workout_id, pass, closes_pass,'
      ' date_str, timestamp, kind) values(1, ?, ?, ?, ?, ?, ?, ?)',
      (phase, workout, pass_, closes, day.isoformat(), ts, kind))

day = dt.date(2026, 7, 6)
for p in range(1, 9):
    for i, w in enumerate([1, 2, 3]):
        event(1, 0, day, w, p, int(i == 2))
        day += dt.timedelta(days=2 if i < 2 else 3)
event(1, 3, dt.date(2026, 8, 31))
day = dt.date(2026, 9, 1)
for p in range(1, 7):
    for i, w in enumerate([4, 5]):
        event(2, 0, day, w, p, int(i == 1))
        day += dt.timedelta(days=3)

db.commit()
print('seeded', sys.argv[1])
