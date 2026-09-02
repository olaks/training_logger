import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

/// Deleting is immediate in this app — there is no trash — so every delete
/// hands back enough to put things back exactly as they were.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a deleted set comes back with the same id and values', () async {
    final cat = await db.insertOrGetCategory('Bench');
    final id = await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: cat,
      dateStr: '2026-01-01',
      timestamp: 7,
      weightKg: const Value(60),
      reps: const Value(5),
      rpe: const Value(8),
    ));

    final deleted = await db.deleteSet(id);
    expect(await db.watchSetsForCategory(cat).first, isEmpty);

    await db.restoreSet(deleted!);
    final back = (await db.watchSetsForCategory(cat).first).single;
    expect(back.id, id);
    expect(back.weightKg, 60);
    expect(back.reps, 5);
    expect(back.rpe, 8);
    expect(back.timestamp, 7);
  });

  test('deleting a set that is already gone reports nothing to undo', () async {
    expect(await db.deleteSet(999999), isNull);
  });

  test('a deleted exercise comes back with its sets and workout slots',
      () async {
    final cat = await db.insertOrGetCategory('Bench', groupName: 'Push');
    await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: cat, dateStr: '2026-01-01', timestamp: 1,
        reps: const Value(5)));
    await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: cat, dateStr: '2026-01-02', timestamp: 2,
        reps: const Value(8)));
    final workout = await db.insertWorkout('Push day');
    await db.addExerciseToWorkout(workout, cat);
    await db.insertInspiration(
        title: 'Setup', url: 'https://example.com', categoryId: cat);

    final deleted = await db.deleteCategory(cat);
    expect(await db.watchWorkoutDates().first, isEmpty);

    await db.restoreCategory(deleted!);

    final cats = await db.watchAllCategories().first;
    final restored = cats.firstWhere((c) => c.id == cat);
    expect(restored.name, 'Bench');
    expect(restored.groupName, 'Push');
    expect(await db.watchSetsForCategory(cat).first, hasLength(2));
    expect(await db.watchExercisesForWorkout(workout).first, hasLength(1));
    expect((await db.watchInspirations().first).single.categoryId, cat,
        reason: 'the saved video is filed under it again');
  });

  test('a deleted workout comes back with its exercises and scheduling',
      () async {
    final cat = await db.insertOrGetCategory('Bench');
    final workout = await db.insertWorkout('Push day');
    await db.addExerciseToWorkout(workout, cat);
    await db.updateWorkoutTarget(
        (await db.watchExercisesForWorkout(workout).first).single.$1, 3, 10);
    final plan = await db.insertPlan('Week');
    await db.assignWorkoutToPlan(plan, workout, weekday: 3);

    final deleted = await db.deleteWorkout(workout);
    expect(await db.watchAllWorkouts().first, isEmpty);
    expect(await db.watchPlanWorkouts(plan).first, isEmpty);

    await db.restoreWorkout(deleted!);

    expect((await db.watchAllWorkouts().first).single.name, 'Push day');
    final members = await db.watchExercisesForWorkout(workout).first;
    expect(members.single.$3, 3);
    expect(members.single.$4, 10);
    expect((await db.watchPlanWorkouts(plan).first).single.weekday, 3);
  });

  test('a deleted plan comes back with its assignments', () async {
    final workout = await db.insertWorkout('Push day');
    final plan = await db.insertPlan('Week');
    await db.assignWorkoutToPlan(plan, workout, weekday: 1);
    await db.assignWorkoutToPlan(plan, workout, dateStr: '2026-01-05');

    final deleted = await db.deletePlan(plan);
    expect(await db.watchAllPlans().first, isEmpty);

    await db.restorePlan(deleted!);

    expect((await db.watchAllPlans().first).single.name, 'Week');
    expect(await db.watchPlanWorkouts(plan).first, hasLength(2));
  });

  test('restoring keeps the database consistent under foreign keys', () async {
    final cat = await db.insertOrGetCategory('Bench');
    await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: cat, dateStr: '2026-01-01', timestamp: 1,
        reps: const Value(5)));

    final deleted = await db.deleteCategory(cat);
    await db.restoreCategory(deleted!);

    // Would throw if a set had been re-inserted before its exercise.
    final orphans = await db
        .customSelect('SELECT COUNT(*) AS c FROM workout_sets '
            'WHERE category_id NOT IN (SELECT id FROM exercise_categories)')
        .getSingle();
    expect(orphans.read<int>('c'), 0);
  });
}
