#!/usr/bin/env bash
# Stops what launch.sh started. The seeded database is kept for the next run;
# delete $RUN_LINUX_DIR to start from a fresh seed.
state=${RUN_LINUX_DIR:-${TMPDIR:-/tmp}/training_logger_run}
for f in app attach hold; do
  [[ -f $state/$f.pid ]] && kill "$(cat "$state/$f.pid")" 2>/dev/null
  rm -f "$state/$f.pid"
done
rm -f "$state/attach.in" "$state/ws"
echo stopped
