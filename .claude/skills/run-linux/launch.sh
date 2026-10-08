#!/usr/bin/env bash
# Launches the Linux debug build against a throwaway database seeded with demo
# plans, and attaches the Flutter tool so that navigate.sh can drive it.
#
# The app keeps its database in the documents directory, which falls back to
# $HOME; pointing HOME elsewhere keeps the user's real database (which may be
# an older schema the build would migrate) out of reach.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
app=$(cd "$here/../../../flutter_app" && pwd)
state=${RUN_LINUX_DIR:-${TMPDIR:-/tmp}/training_logger_run}
mkdir -p "$state/home"
bin=$app/build/linux/x64/debug/bundle/training_logger
db=$state/home/training_logger.sqlite

[[ -n ${SKIP_BUILD:-} ]] || (cd "$app" && flutter build linux --debug)

run_app() {
  HOME=$state/home XDG_CONFIG_HOME=$state/home/.config \
    XDG_DATA_HOME=$state/home/.local/share GDK_BACKEND=x11 \
    setsid "$bin" > "$state/app.log" 2>&1 < /dev/null &
  echo $! > "$state/app.pid"
}

# The first launch creates the schema; the seed goes in once the app is shut.
if [[ ! -f $db ]]; then
  run_app
  for _ in $(seq 60); do [[ -f $db ]] && break; sleep 0.5; done
  sleep 2
  kill "$(cat "$state/app.pid")"
  sleep 1
  python3 "$here/seed_demo.py" "$db"
fi

run_app
for _ in $(seq 60); do grep -q 'VM service' "$state/app.log" && break; sleep 0.5; done
url=$(grep -o 'http://127.0.0.1:[0-9]*/[^ ]*' "$state/app.log" | tail -1)

# `flutter attach` brings the expression compiler that evaluating Dart in the
# app needs. It quits on EOF, so its stdin is a fifo held open.
rm -f "$state/attach.in"
mkfifo "$state/attach.in"
# Every background child gets all three streams redirected, or it holds the
# caller's pipe open and `launch.sh | tail` never returns.
setsid sleep infinity > "$state/attach.in" 2> /dev/null < /dev/null &
echo $! > "$state/hold.pid"
(cd "$app" && setsid flutter attach -d linux --debug-url "$url" \
  < "$state/attach.in" > "$state/attach.log" 2>&1 &
  echo $! > "$state/attach.pid")
for _ in $(seq 90); do
  grep -q 'Dart VM Service on Linux' "$state/attach.log" && break
  sleep 2
done
grep -o 'http://127.0.0.1:[0-9]*/[^ /]*=/' "$state/attach.log" | tail -1 \
  | sed 's#^http#ws#; s#$#ws#' > "$state/ws"
echo "ready: $(cat "$state/ws")"
