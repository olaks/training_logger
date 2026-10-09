import 'package:drift/drift.dart';

// ── Workouts (reusable named sets of exercises) ───────────────────────────────

class Workouts extends Table {
  IntColumn  get id    => integer().autoIncrement()();
  TextColumn get name  => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

@TableIndex(name: 'idx_we_workout', columns: {#workoutId, #sortOrder})
@TableIndex(name: 'idx_we_category', columns: {#categoryId})
class WorkoutExercises extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get workoutId  => integer().references(Workouts, #id)();
  IntColumn get categoryId => integer().references(ExerciseCategories, #id)();
  IntColumn get targetSets => integer().nullable()();
  IntColumn get targetReps => integer().nullable()();
  IntColumn get targetRpe  => integer().nullable()(); // 1–10, null = no target
  IntColumn get sortOrder  => integer().withDefault(const Constant(0))();
}

// ── Plans (schedules that assign Workouts to days) ────────────────────────────

class Plans extends Table {
  IntColumn  get id     => integer().autoIncrement()();
  TextColumn get name   => text()();
  // Inactive plans keep their contents but schedule nothing. At most one
  // active plan may have phases — see [PlanPhases].
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  // Days in a microcycle of each of this plan's phases. Plans that were
  // periodized before microcycles migrated as 1: one day, holding the whole
  // old rotation.
  IntColumn  get cycleDays => integer().withDefault(const Constant(8))();
}

@TableIndex(name: 'idx_pw_plan', columns: {#planId})
@TableIndex(name: 'idx_pw_workout', columns: {#workoutId})
class PlanWorkouts extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  IntColumn  get planId    => integer().references(Plans, #id)();
  IntColumn  get workoutId => integer().references(Workouts, #id)();
  TextColumn get dateStr   => text().nullable()();    // "yyyy-MM-dd" one-off
  IntColumn  get weekday   => integer().nullable()(); // 1=Mon…7=Sun recurring
}

// ── Periodized plans ──────────────────────────────────────────────────────────
//
// A plan with phases is periodized: it runs its phases in order, and each
// phase lasts a number of *passes* through its rotation of sessions rather than
// a number of days, so missed days never move the plan. Where the plan stands
// is never stored — it is replayed from [PlanEvents] by
// `utils/periodization.dart`, so undo and editing a phase mid-plan come free.

@TableIndex(name: 'idx_phase_plan', columns: {#planId, #sortOrder})
class PlanPhases extends Table {
  IntColumn  get id           => integer().autoIncrement()();
  IntColumn  get planId       => integer().references(Plans, #id)();
  IntColumn  get sortOrder    => integer().withDefault(const Constant(0))();
  TextColumn get name         => text()();
  IntColumn  get lengthPasses => integer()();
  IntColumn  get deloadEvery  => integer().nullable()(); // null = no scheduled deloads
}

/// A phase's microcycle: one row per workout on a day, in order within the
/// day. A day with no rows is a rest day.
@TableIndex(name: 'idx_ps_phase', columns: {#phaseId, #sortOrder})
@TableIndex(name: 'idx_ps_workout', columns: {#workoutId})
class PhaseSessions extends Table {
  IntColumn get id        => integer().autoIncrement()();
  IntColumn get phaseId   => integer().references(PlanPhases, #id)();
  IntColumn get workoutId => integer().references(Workouts, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get day       => integer().withDefault(const Constant(1))(); // 1-based day of the cycle
}

/// A phase's targets for one exercise, overriding the workout's own for every
/// workout in that phase. A null field falls back to the workout's value.
@TableIndex(name: 'idx_pet_phase', columns: {#phaseId})
@TableIndex(name: 'idx_pet_category', columns: {#categoryId})
class PhaseExerciseTargets extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get phaseId    => integer().references(PlanPhases, #id)();
  IntColumn get categoryId => integer().references(ExerciseCategories, #id)();
  IntColumn get targetRpe  => integer().nullable()();
  IntColumn get targetSets => integer().nullable()();
  IntColumn get targetReps => integer().nullable()();
}

/// Stored by index: append new kinds, never reorder.
enum PlanEventKind {
  /// A session in the current pass was done.
  done,

  /// A session in the current pass was deliberately not done.
  skip,

  /// "Deload now": the next pass that hasn't started becomes a deload.
  deload,

  /// The athlete confirmed moving on from a phase.
  advance,
}

@TableIndex(name: 'idx_pe_plan', columns: {#planId, #timestamp})
@TableIndex(name: 'idx_pe_phase', columns: {#phaseId})
@TableIndex(name: 'idx_pe_workout', columns: {#workoutId})
class PlanEvents extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  IntColumn  get planId    => integer().references(Plans, #id)();
  IntColumn  get phaseId   => integer().references(PlanPhases, #id)();
  IntColumn  get workoutId => integer().nullable().references(Workouts, #id)(); // done / skip only
  // done / skip only: the 1-based cycle (pass) of the phase and day of the
  // cycle it was recorded in. Days before the latest one stamped are finished
  // whatever the cycle holds now, so editing it mid-plan can't undo days
  // already trained.
  IntColumn  get pass      => integer().nullable()();
  IntColumn  get day       => integer().nullable()();
  // done / skip only: it was the last workout still due on its day, so the
  // day was finished then — even if a workout has been added to it since.
  // A skip with no workout is "skip rest day".
  BoolColumn get closesDay => boolean().withDefault(const Constant(false))();
  TextColumn get dateStr   => text()();
  IntColumn  get timestamp => integer()();
  IntColumn  get kind      => intEnum<PlanEventKind>()();
}

// ── Exercises / sets ──────────────────────────────────────────────────────────

class ExerciseCategories extends Table {
  IntColumn  get id           => integer().autoIncrement()();
  TextColumn get name         => text()();
  TextColumn get groupName    => text().nullable()();
  TextColumn get description  => text().nullable()();
  // 0 = standard (weight/reps/time), 1 = climbing (grade)
  IntColumn  get exerciseType => integer().withDefault(const Constant(0))();
}

/// Exercise photos, kept out of [ExerciseCategories] on purpose.
///
/// A category row is read by nearly every screen — the day view, the load
/// series, every exercise picker — and none of them draw the picture. Holding
/// the blob on the row meant each of those reads dragged every photo out of
/// SQLite and into memory. In its own table the bytes are fetched only by the
/// two widgets that actually show them.
class ExerciseImages extends Table {
  IntColumn  get categoryId => integer().references(ExerciseCategories, #id)();
  BlobColumn get data       => blob()();

  @override
  Set<Column> get primaryKey => {categoryId};
}

// A set is looked up two ways: everything on one day (the day view), and
// everything for one exercise (history, graph, prefill). Both orderings are
// carried by the index so neither has to sort the table.
@TableIndex(name: 'idx_sets_date', columns: {#dateStr, #timestamp})
@TableIndex(name: 'idx_sets_category', columns: {#categoryId, #dateStr})
class WorkoutSets extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  IntColumn  get categoryId => integer().references(ExerciseCategories, #id)();
  TextColumn get dateStr    => text()();
  IntColumn  get timestamp  => integer()();
  RealColumn get weightKg   => real().nullable()();
  IntColumn  get reps       => integer().nullable()();
  IntColumn  get timeSecs   => integer().nullable()();
  IntColumn  get rpe        => integer().nullable()(); // 1–10, null = not recorded
  TextColumn get grade      => text().nullable()();   // climbing grade string, null for standard sets
  IntColumn  get wallAngle  => integer().nullable()(); // climbing wall angle in degrees, null = not recorded
  TextColumn get climbName  => text().nullable()();   // climbing route/problem name, null = not recorded
}

// ── Day notes (one free-text note per calendar day) ───────────────────────────

class DayNotes extends Table {
  TextColumn get dateStr => text()();
  TextColumn get note    => text()();

  @override
  Set<Column> get primaryKey => {dateStr};
}

// ── Body weight log ───────────────────────────────────────────────────────────

class BodyWeights extends Table {
  TextColumn get dateStr => text()();
  RealColumn get kg      => real()();

  @override
  Set<Column> get primaryKey => {dateStr};
}

// ── Inspirations (saved YouTube/web videos, optionally tied to an exercise) ───

@TableIndex(name: 'idx_inspirations_category', columns: {#categoryId})
class Inspirations extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  TextColumn get title      => text()();
  TextColumn get url        => text()();
  TextColumn get notes      => text().nullable()();
  IntColumn  get categoryId => integer().nullable().references(ExerciseCategories, #id)();
  IntColumn  get addedAt    => integer()();
}
