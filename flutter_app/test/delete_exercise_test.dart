import 'dart:io';
import 'dart:typed_data';

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

  group('exercise photos', () {
    test('a deleted exercise takes its photo, and an undo brings it back',
        () async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.setCategoryImage(bench, Uint8List.fromList([4, 5, 6]));

      final deleted = await db.deleteCategory(bench);
      expect(await countOf('exercise_images'), 0);

      await db.restoreCategory(deleted!);
      final restored = (await db.watchAllCategories().first)
          .firstWhere((c) => c.name == 'Bench');
      expect(await db.getCategoryImage(restored.id), [4, 5, 6]);
    });

    test('clearing a photo removes the row rather than storing nothing',
        () async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.setCategoryImage(bench, Uint8List.fromList([1]));
      await db.setCategoryImage(bench, null);

      expect(await db.getCategoryImage(bench), isNull);
      expect(await countOf('exercise_images'), 0);
    });
  });

  group('renameCategory', () {
    test('refuses a name another exercise already answers to', () async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.insertOrGetCategory('Squat');

      expect(() => db.renameCategory(bench, 'squat'),
          throwsA(isA<DuplicateNameException>()),
          reason: 'two exercises of the same name make a backup ambiguous');
      expect((await db.watchAllCategories().first).map((c) => c.name),
          containsAll(['Bench', 'Squat']));
    });

    test('lets an exercise keep its own name', () async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.renameCategory(bench, 'Bench Press');
      await db.renameCategory(bench, 'Bench Press');

      final names = (await db.watchAllCategories().first).map((c) => c.name);
      expect(names, contains('Bench Press'));
      expect(names, isNot(contains('Bench')));
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
