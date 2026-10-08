#!/usr/bin/env bash
# Opens a route in the running app, e.g. `navigate.sh /plans/2`. Anything else
# a Dart expression in app.dart's scope can do works too: `navigate.sh -e EXPR`.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
app=$(cd "$here/../../../flutter_app" && pwd)
state=${RUN_LINUX_DIR:-${TMPDIR:-/tmp}/training_logger_run}
if [[ $1 == -e ]]; then expr=$2; else expr="router.go('$1')"; fi
dart run --packages="$app/.dart_tool/package_config.json" \
  "$here/navigate.dart" "$(cat "$state/ws")" "$expr" 2>/dev/null \
  | grep -v '^Running build hooks'
