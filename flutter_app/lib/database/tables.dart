import 'package:drift/drift.dart';

// ── Workouts (reusable named sets of exercises) ───────────────────────────────

class Workouts extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text()();
}

class WorkoutExercises extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get workoutId  => integer().references(Workouts, #id)();
  IntColumn get categoryId => integer().references(ExerciseCategories, #id)();
  IntColumn get targetSets => integer().nullable()();
  IntColumn get targetReps => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{workoutId, categoryId}];
}

// ── Plans (schedules that assign Workouts to days) ────────────────────────────

class Plans extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text()();
}

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
  BlobColumn get imageData    => blob().nullable()();
  // 0 = standard (weight/reps/time), 1 = climbing (grade)
  IntColumn  get exerciseType => integer().withDefault(const Constant(0))();
}

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
