import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:training_logger/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addSet(int catId, String date) =>
      db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr: date,
        timestamp: 1,
        reps: const Value(5),
      ));

  Future<int> countOf(String table) async {
    final rows = await db.customSelect('SELECT COUNT(*) AS c FROM $table').get();
    return rows.single.read<int>('c');
  }

  test('foreign keys are enforced once the database is open', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('a set cannot reference an exercise that does not exist', () async {
    expect(
      () => db.insertSet(WorkoutSetsCompanion.insert(
          categoryId: 999999, dateStr: '2026-01-01', timestamp: 1)),
      throwsA(anything),
    );
  });

  group('deleteCategory', () {
    test('takes logged sets and workout memberships with it', () async {
      final bench = await db.insertOrGetCategory('Bench');
      final squat = await db.insertOrGetCategory('Squat');
      await addSet(bench, '2026-01-01');
      await addSet(bench, '2026-01-02');
      await addSet(squat, '2026-01-01');

      final workout = await db.insertWorkout('Push day');
      await db.addExerciseToWorkout(workout, bench);
      await db.addExerciseToWorkout(workout, squat);

      await db.deleteCategory(bench);

      expect(await countOf('workout_sets'), 1, reason: 'only squat survives');
      expect(await countOf('workout_exercises'), 1);
      final remaining = await db.watchAllCategories().first;
      expect(remaining.map((c) => c.name), isNot(contains('Bench')));
    });

    test('leaves no day marked as trained by the deleted exercise', () async {
      final bench = await db.insertOrGetCategory('Bench');
      await addSet(bench, '2026-01-01');

      await db.deleteCategory(bench);

      expect(await db.watchWorkoutDates().first, isEmpty);
    });

    test('keeps saved videos, unlinking them from the exercise', () async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.insertInspiration(
          title: 'Bench setup', url: 'https://example.com', categoryId: bench);

      await db.deleteCategory(bench);

      final all = await db.watchInspirations().first;
      expect(all, hasLength(1));
      expect(all.single.categoryId, isNull);
    });

    test('reports what it will remove before deleting', () async {
      final bench = await db.insertOrGetCategory('Bench');
      await addSet(bench, '2026-01-01');
      await addSet(bench, '2026-01-02');
      final workout = await db.insertWorkout('Push day');
      await db.addExerciseToWorkout(workout, bench);
      // Same exercise twice in one workout still counts as one workout.
      await db.addExerciseToWorkout(workout, bench);

      final impact = await db.categoryDeletionImpact(bench);
      expect(impact.sets, 2);
      expect(impact.workouts, 1);

      final untouched = await db.insertOrGetCategory('Squat');
      expect(await db.categoryDeletionImpact(untouched),
          (sets: 0, workouts: 0));
    });
  });

  group('migration to v16', () {
    late Directory dir;
    late File file;

    setUp(() {
      // The test deliberately opens the same file twice, in sequence.
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      dir = Directory.systemTemp.createTempSync('training_logger_test');
      file = File('${dir.path}/db.sqlite');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('clears rows orphaned by the old delete, then enforces keys',
        () async {
      // Create the schema, then throw away the connection.
      final fresh = AppDatabase.forTesting(NativeDatabase(file));
      final bench = await fresh.insertOrGetCategory('Bench');
      await fresh.insertSet(WorkoutSetsCompanion.insert(
          categoryId: bench, dateStr: '2026-01-01', timestamp: 1));
      await fresh.close();

      // Reproduce what the old deleteCategory left behind: the exercise gone,
      // its sets still there. Rewind the version so the upgrade path runs.
      final raw = sqlite3.open(file.path);
      raw.execute('DELETE FROM exercise_categories WHERE id = $bench');
      raw.execute('PRAGMA user_version = 15');
      expect(raw.select('SELECT * FROM workout_sets'), hasLength(1));
      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      expect(await upgraded.watchWorkoutDates().first, isEmpty,
          reason: 'the orphaned day should no longer look trained');
      final fk = await upgraded.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.read<int>('foreign_keys'), 1);
      await upgraded.close();
    });
  });
}
