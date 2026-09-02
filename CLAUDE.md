# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Training Logger is a climbing and strength training logger. The active app is in `flutter_app/` — a Flutter project targeting Android, iOS, Web (WASM), and Linux desktop from a single Dart codebase. There is also a legacy `app/` directory containing a Jetpack Compose Android prototype (not actively developed).

## Build and run commands

All commands run from `flutter_app/`:

```bash
flutter pub get                        # install dependencies
flutter run                            # run on connected device (debug)
flutter run -d web-server --web-port 8080  # run web version locally
flutter run -d linux                   # run Linux desktop version
flutter build apk --release            # release APK
flutter build web --release            # release web build
flutter build linux --release          # release Linux build
```

Rebuild Drift-generated code after changing database tables or queries:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Rebuild the web SQLite worker (only after major `drift` version upgrades):

```bash
dart compile js -O2 -o web/drift_worker.js lib/drift_worker.dart
```

Run tests:

```bash
flutter test                           # all tests
flutter test test/backup_test.dart     # single test file
```

Widget tests run in fake time, where a real database never answers: wrap drift
calls in `tester.runAsync`, and advance the clock a millisecond before the tree
is torn down so drift's stream-close timer can run.

## Architecture

### Stack

- **State management:** Riverpod (providers + StateNotifier for transient UI state)
- **Database:** Drift (SQLite) with code generation — schema version 16, foreign keys enforced
- **Routing:** go_router (URL-based, important for web)
- **UI:** Material 3 with custom dark themes (4 accent colors)

### Code layout (`flutter_app/lib/`)

| Directory | Purpose |
|-----------|---------|
| `database/` | Drift database class, table definitions (`tables.dart`), migrations, JSON export/import |
| `providers/` | Riverpod providers: `dbProvider` singleton, stream providers for reactive data, `TrackNotifier` for stepper state, `DbMutations` extension for writes |
| `screens/` | UI organized by feature: `home/`, `exercises/`, `detail/` (Track/History/Graph tabs, edit-set sheet, shared set inputs), `plans/`, `import/`, `settings/`, `hangboard/`, `inspiration/` |
| `theme/` | Material 3 theme builder and accent color definitions |
| `utils/` | Date formatting, climbing grade scales (Font/V-scale), display formatters, `PhaseCountdown` (shared by all three timers), body-weight lookup, file picking, undo snackbar |

### Data flow

Providers expose Drift streams → UI widgets `watch()` providers and rebuild reactively. Writes go through `DbMutations` extension methods on `WidgetRef`. Each exercise's Track tab gets its own `TrackNotifier` (keyed by categoryId via `autoDispose.family`).

### Database

Tables are defined in `database/tables.dart`. Key entities: `ExerciseCategories` (the exercise library, with `exerciseType` 0=standard/1=climbing), `WorkoutSets` (logged sets with weight/reps/time/rpe/grade), `Workouts`/`WorkoutExercises` (reusable templates), `Plans`/`PlanWorkouts` (weekly scheduling), `DayNotes`, `BodyWeights`.

Migrations are incremental in `database.dart` — each `if (from < N)` block handles one schema version. When adding columns or tables, bump `schemaVersion` and add a new migration block.

Foreign keys are enforced (`PRAGMA foreign_keys = ON` in `beforeOpen`), so a delete must clear its children. The delete methods return a snapshot (`DeletedCategory`, `DeletedWorkout`, `DeletedPlan`, or the removed `WorkoutSet`) that the matching `restore*` method puts back — that is how undo works.

After changing the schema, dump it so future migrations can be verified against this version:

```bash
dart run drift_dev schema dump lib/database/database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

`test/schema_test.dart` checks that a migrated database ends up with the same schema as a fresh install.

### Pinned dependencies

Two holds in `pubspec.yaml`, both worth revisiting when the Flutter SDK or the toolchain moves:

- `drift` below 2.34.1 — newer versions break `drift_dev`'s schema verifier, and the `drift_dev` release that fixes it needs a newer analyzer than this Flutter SDK allows. Lift both together.
- `jni` overridden to 1.0.0 — it comes in transitively via `path_provider_android` and is Android-only, but its C sources are still compiled for the Linux desktop build, where 1.0.1+ fails to compile.
- `file_picker`, `share_plus` and `wakelock_plus` held on the win32 5 line — file_picker 12 and share_plus 13 need win32 6, which forces wakelock_plus 1.6+, whose Android sources don't compile ("Unresolved reference 'ToggleMessage'"). Move all three together.

A stale Gradle cache can survive a dependency change and fail the APK build with a missing plugin class; `flutter clean` clears it.

### Routes

Defined in `app.dart`. Shell route with bottom nav (Home `/`, Exercises `/exercises`, Plans `/plans`, Timer `/hangboard`). Detail routes: `/exercise/:id/:date`, `/exercise/:id/edit`, `/workouts/:id`, `/workout-session/:id/:date`, `/plans/:id`, `/hangboard-session/:exerciseId`, `/import`, `/inspirations`, `/settings`.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) runs on push to main: builds APK, Linux bundle, and web (deployed to GitHub Pages). Creates a `latest` GitHub release with the APK and Linux zip. No test step in CI.

## Web deployment note

Web version uses WebAssembly SQLite and requires these HTTP headers on the hosting server:
```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```
The Flutter dev server sets these automatically.
