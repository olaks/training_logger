import 'package:drift/drift.dart';

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
