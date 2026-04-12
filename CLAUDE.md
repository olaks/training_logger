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
flutter test test/widget_test.dart     # single test file
```

## Architecture

### Stack

- **State management:** Riverpod (providers + StateNotifier for transient UI state)
- **Database:** Drift (SQLite) with code generation — schema version 10
- **Routing:** go_router (URL-based, important for web)
- **UI:** Material 3 with custom dark themes (4 accent colors)

### Code layout (`flutter_app/lib/`)

| Directory | Purpose |
|-----------|---------|
| `database/` | Drift database class, table definitions (`tables.dart`), migrations, JSON export/import |
| `providers/` | Riverpod providers: `dbProvider` singleton, stream providers for reactive data, `TrackNotifier` for stepper state, `DbMutations` extension for writes |
| `screens/` | UI organized by feature: `home/`, `exercises/`, `detail/` (Track/History/Graph tabs), `plans/`, `import/` |
| `theme/` | Material 3 theme builder and accent color definitions |
| `utils/` | Date formatting, climbing grade scales (Font/V-scale), display formatters |

### Data flow

Providers expose Drift streams → UI widgets `watch()` providers and rebuild reactively. Writes go through `DbMutations` extension methods on `WidgetRef`. Each exercise's Track tab gets its own `TrackNotifier` (keyed by categoryId via `autoDispose.family`).

### Database

Tables are defined in `database/tables.dart`. Key entities: `ExerciseCategories` (the exercise library, with `exerciseType` 0=standard/1=climbing), `WorkoutSets` (logged sets with weight/reps/time/rpe/grade), `Workouts`/`WorkoutExercises` (reusable templates), `Plans`/`PlanWorkouts` (weekly scheduling), `DayNotes`, `BodyWeights`.

Migrations are incremental in `database.dart` — each `if (from < N)` block handles one schema version. When adding columns or tables, bump `schemaVersion` and add a new migration block.

### Routes

Defined in `app.dart`. Shell route with bottom nav (Home `/`, Exercises `/exercises`, Plans `/plans`). Detail routes: `/exercise/:id/:date`, `/workouts/:id`, `/plans/:id`, `/import`.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) runs on push to main: builds APK, Linux bundle, and web (deployed to GitHub Pages). Creates a `latest` GitHub release with the APK and Linux zip. No test step in CI.

## Web deployment note

Web version uses WebAssembly SQLite and requires these HTTP headers on the hosting server:
```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```
The Flutter dev server sets these automatically.
