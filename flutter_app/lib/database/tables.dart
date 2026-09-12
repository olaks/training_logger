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
  IntColumn get sortOrder  => integer().withDefault(const Constant(0))();
}

// ── Plans (schedules that assign Workouts to days) ────────────────────────────

class Plans extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text()();
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
