---
name: run-linux
description: Launch the Flutter app as a Linux desktop build on a throwaway seeded database, open any route, and screenshot the window. Use to see a UI change running in the real app.
---

# Run the Linux build and screenshot it

Scripts are in this directory. Run them from anywhere.

```bash
.claude/skills/run-linux/launch.sh          # build, seed on first run, launch, attach
.claude/skills/run-linux/navigate.sh /plans/1
python3 .claude/skills/run-linux/screenshot.py "$TMPDIR/shot.png"   # then Read the PNG
.claude/skills/run-linux/stop.sh
```

Set `SKIP_BUILD=1` on `launch.sh` when the bundle is current. State, logs and
the database live in `$RUN_LINUX_DIR` (default `$TMPDIR/training_logger_run`).
Delete that directory to reseed.

## Why it is done this way

- **Never the real database.** The app keeps its database in the documents
  directory, which is `~/Documents/training_logger.sqlite`. That file can be
  an older schema, and opening it with a new build migrates it for good.
  `launch.sh` points `HOME` at the state directory instead.
- **Navigation goes through the VM service, not clicks.** The desktop is
  Wayland. GTK drops synthetic X events, XTest clicks don't reach the
  XWayland window, and the `route=` engine switch is ignored on this build.
  `flutter attach` provides the expression compiler, so `navigate.sh`
  evaluates `router.go(...)` in `app.dart`. Use `navigate.sh -e '<expr>'` for
  any other expression in that scope.
- **The demo data is in `seed_demo.py`.** Plan 1 is running, with one phase
  done and one in progress, and the dates assume 2026-10-08. Plan 2 is
  stopped and has never run. Add rows there when a screen needs more.

## Gotchas

- Never call `import -window` with an empty id. It waits for a mouse click
  and hangs. `screenshot.py` finds the window by class instead.
- `pkill -f training_logger` matches the shell running it and kills that
  shell too. `stop.sh` kills by saved pid.
