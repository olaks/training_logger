# Periodized plans: design plan

Goal: use the logger to run a plan that spans many weeks, up to a whole year,
in phases (Capacity → Basic strength → Max strength …). Each phase has its own
rotation of sessions and its own target RPEs, with regular deloads.

Status: implementation order 1–5 done, shipped in v1.6.0 (schema v18 is now
frozen). Open work is the **Later** list below. "Where the logger is now"
describes the app before this work began.

## Where the logger is now

- **`Plans` / `PlanWorkouts`**: a plan is a set of workout assignments, each
  either recurring on a weekday or on one date. No start, no end, no "active"
  flag; every plan's assignments show forever.
- **Targets**: `WorkoutExercises` stores only `targetSets` and `targetReps`.
- **Sessions**: nothing records that a workout was done. `WorkoutSets` has no
  `workoutId`; a set is an exercise and a date.

## Model

A periodized plan is a `Plans` row with phases. It is **session-based, not
calendar-based**: a phase lasts a number of *passes*, a pass is one trip
through the phase's rotation of sessions (A, B, C), and a pass is what the UI
calls a "week". Missing days don't move the plan; only completed sessions do.

```
Plan (active, periodized)
  └─ Phase "Capacity"   10 passes, rotation [A, B, C], deload every 4th pass
       ├─ PhaseSessions   A = workout 3, B = workout 7, C = workout 9
       └─ PhaseExerciseTargets   squat → RPE 7, deadlift → RPE 7
```

### Decisions

| Topic | Decision |
|---|---|
| How phases differ | Both different workouts (each phase has its own rotation) and different intensity (RPE overrides). |
| Intensity | Target RPE only. `WorkoutExercises.targetRpe` is the default; `PhaseExerciseTargets(phaseId, categoryId, targetRpe?, sets?, reps?)` overrides it for every workout in that phase containing the exercise. |
| Scheduling | Rotation queue, no weekdays. Home shows what is left in the current pass ("Remaining this week: B, C"); any of them can be done in any order. A pass completes when each session is done or explicitly skipped. |
| Completion | Explicit. "Finish session" on any workout that belongs to the current pass counts, wherever it was opened from. |
| Deloads | A deload is one pass in which every target becomes **RPE 5**, shown with a deload flag. Scheduled by a per-phase rule (`deloadEvery` passes) and counted inside the phase length (10 passes, deload every 4th = passes 4 and 8 are deloads). A manual "Deload now" makes the next pass a deload; if a scheduled deload is within 2 passes it replaces that one, otherwise it is inserted and the phase grows by one pass. |
| Progress | Chip: **"Capacity · week 5/10 · deload in 2"**. Raw session counts on the plan detail screen. |
| Phase boundary | Ask before moving on ("Capacity done, start Basic strength?"), so a phase can be extended. |
| End of plan | Stop. No repeat; copy the plan to run it again. |
| Concurrency | At most one active periodized plan. Weekly plans keep working alongside it. |
| Active plans | `Plans.active` flag on every plan; inactive plans don't show on home. |
| Progress state | Derived, never stored: a pure resolver replays the event log against the phases. |
| Track tab | Label `4×6 @ RPE 8` (or `@ RPE 5 · Deload` in the warning colour), and the RPE input of a new set is prefilled with the target. |

### Schema (v18)

| Change | Purpose |
|---|---|
| `Plans.active` (bool, default true) | Hide finished plans. Existing plans migrate as active, so nothing changes for them. |
| `PlanPhases(id, planId, sortOrder, name, lengthPasses, deloadEvery?, color)` | One block of the plan. A plan with phases is periodized; its weekday `PlanWorkouts` are not used. |
| `PhaseSessions(id, phaseId, workoutId, sortOrder)` | The phase's rotation. |
| `PhaseExerciseTargets(id, phaseId, categoryId, targetRpe?, targetSets?, targetReps?)` | Per-phase overrides by exercise. |
| `WorkoutExercises.targetRpe` (nullable int) | Default target RPE. |
| `PlanEvents(id, planId, phaseId, workoutId?, dateStr, timestamp, kind)` | The log: `done`, `skip`, `deload` (manual), `advance` (confirmed next phase). |

Following CLAUDE.md: bump `schemaVersion`, add the `from < 18` block, declare
indexes with `@TableIndex` and create them in the migration, dump the schema
and regenerate the migration tests, make deletes clear children, and extend
`DeletedPlan` so undo restores phases, sessions, targets and events.
Deleting a workout used in a `PhaseSessions` row must be handled the same way
as one used in `PlanWorkouts`.

### Resolver: `utils/periodization.dart`

Pure functions, no Flutter, in the style of `training_load.dart`:

```dart
PlanState resolvePlan(List<PlanPhase> phases,
                      Map<int, List<PhaseSession>> rotations,
                      List<PlanEvent> events);
// → current phase, pass number, sessions remaining in the pass,
//   whether this pass is a deload, passes until next deload,
//   phaseComplete (waiting for an `advance`), planComplete

Target resolveTarget(WorkoutExercise base, PhaseExerciseTarget? override,
                     {required bool deload});
// deload → RPE 5; else override ?? base
```

Because state is derived, undo is "delete the event", and editing a phase's
length or rotation mid-plan just re-resolves.

## UI (v1)

1. **Plans screen**: active toggle per plan; "New periodized plan".
2. **Plan detail**: weekday grid for weekly plans, phase editor for periodized
   ones: ordered phases, each with name, length in passes, deload rule,
   rotation (pick workouts) and RPE overrides per exercise. Shows session
   counts and position in the current pass.
3. **Home**: the phase chip, "Remaining this week: B, C" with Skip, "Deload
   now", and the "start next phase?" prompt when a phase completes.
4. **Workout session screen**: "Finish session" writes a `done` event when the
   workout is in the current pass.
5. **Track tab**: target label with RPE and deload flag; RPE prefill.
6. **Workout edit sheet**: target RPE per exercise.

## Later

- **Projected timeline** (first): estimated dates for each phase from your
  recent session frequency, with deloads marked — makes the year visible.
- "You logged sets for B today, mark it done?" prompt.
- Generator wizard with phase presets.
- Phase and deload bands behind the ACWR chart.

## Implementation order

1. **Model and resolver**: schema v18, migration, schema dump, and
   `periodization.dart` with tests (pass completion with skips and
   out-of-order sessions, deload placement, manual deload replacing or
   inserting, phase completion awaiting `advance`, plan end, editing a phase
   mid-plan). Nothing visible changes yet.
2. **Target RPE**: `WorkoutExercises.targetRpe` in the workout edit sheet,
   Track tab label and prefill (works for weekly plans too).
3. **Phase editor** in plan detail, and the `active` flag.
4. **Running a plan**: events from "Finish session", Skip, Deload now and
   advance; home chip and queue; resolved targets on the Track tab.
5. **Backup**: plan export/import and the full backup include the new tables,
   with a round-trip test in `backup_test.dart`.
