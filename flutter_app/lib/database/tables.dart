import 'package:drift/drift.dart';

// ── Workout plans ─────────────────────────────────────────────────────────────

class Plans extends Table {
  IntColumn  get id   => integer().autoIncrement()();
  TextColumn get name => text()();
}

class PlanExercises extends Table {
  IntColumn get id         => integer().autoIncrement()();
  IntColumn get planId     => integer().references(Plans, #id)();
  IntColumn get categoryId => integer().references(ExerciseCategories, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [{planId, categoryId}];
}

class ScheduledPlans extends Table {
  IntColumn  get id      => integer().autoIncrement()();
  IntColumn  get planId  => integer().references(Plans, #id)();
  TextColumn get dateStr => text().nullable()();    // "yyyy-MM-dd" one-off
  IntColumn  get weekday => integer().nullable()(); // 1=Mon…7=Sun recurring
}

// ── Exercises / sets ──────────────────────────────────────────────────────────

class ExerciseCategories extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get name      => text()();
  TextColumn get groupName => text().nullable()();   // e.g. "Fingers", "Back"
  BlobColumn get imageData => blob().nullable()();
}

class WorkoutSets extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  IntColumn  get categoryId => integer().references(ExerciseCategories, #id)();
  TextColumn get dateStr    => text()();           // "yyyy-MM-dd"
  IntColumn  get timestamp  => integer()();         // epoch ms
  RealColumn get weightKg   => real().nullable()();
  IntColumn  get reps       => integer().nullable()();
  IntColumn  get timeSecs   => integer().nullable()();
}
