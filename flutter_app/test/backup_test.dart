import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

/// The JSON export is the only way training history leaves the device, so a
/// round trip has to come back whole.
void main() {
  late AppDatabase source;

  setUp(() {
    // Each test opens a second database to restore into.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    source = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => source.close());

  /// Populates [db] with one of everything the export claims to carry.
  Future<void> seed(AppDatabase db) async {
    final hang = await db.insertOrGetCategory('Edge Lift 18 mm',
        groupName: 'Finger Strength', description: '18 mm edge, half crimp');
    final boulder = await db.insertOrGetCategory('Comp Boulder',
        groupName: 'Bouldering');
    await db.setExerciseType(boulder, 1);

    await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: hang,
      dateStr: '2026-01-01',
      timestamp: 1,
      weightKg: const Value(22.5),
      timeSecs: const Value(10),
      rpe: const Value(8),
    ));
    await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: boulder,
      dateStr: '2026-01-02',
      timestamp: 2,
      grade: const Value('7A'),
      wallAngle: const Value(40),
      climbName: const Value('Blue arete'),
    ));

    final workout = await db.insertWorkout('Board session');
    await db.updateWorkoutNotes(workout, 'Warm up first');
    await db.addExerciseToWorkout(workout, hang);
    await db.addExerciseToWorkout(workout, boulder);
    await db.updateWorkoutTarget(
        (await db.watchExercisesForWorkout(workout).first).first.$1, 4, 6);

    final plan = await db.insertPlan('Winter');
    await db.assignWorkoutToPlan(plan, workout, weekday: 2);

    await db.saveDayNote('2026-01-01', 'Felt strong');
    await db.saveBodyWeight('2026-01-01', 71.5);
    await db.insertInspiration(
        title: 'Hangboard basics',
        url: 'https://example.com/hangs',
        notes: 'good protocol',
        categoryId: hang);
  }

  test('a backup restores into an empty database intact', () async {
    await seed(source);
    final json = await source.exportToJson();

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    await restored.importFromJson(json);

    final cats = await restored.watchAllCategories().first;
    final hang = cats.firstWhere((c) => c.name == 'Edge Lift 18 mm');
    expect(hang.groupName, 'Finger Strength');
    expect(hang.description, '18 mm edge, half crimp');
    final boulder = cats.firstWhere((c) => c.name == 'Comp Boulder');
    expect(boulder.exerciseType, 1);

    final hangSets = await restored.watchSetsForCategory(hang.id).first;
    expect(hangSets.single.weightKg, 22.5);
    expect(hangSets.single.timeSecs, 10);
    expect(hangSets.single.rpe, 8);

    final climbs = await restored.watchSetsForCategory(boulder.id).first;
    expect(climbs.single.grade, '7A');
    expect(climbs.single.wallAngle, 40);
    expect(climbs.single.climbName, 'Blue arete');

    final workouts = await restored.watchAllWorkouts().first;
    expect(workouts.single.name, 'Board session');
    expect(workouts.single.notes, 'Warm up first');
    final members =
        await restored.watchExercisesForWorkout(workouts.single.id).first;
    expect(members.map((m) => m.$2.name), ['Edge Lift 18 mm', 'Comp Boulder']);
    expect(members.first.$3, 4, reason: 'target sets');
    expect(members.first.$4, 6, reason: 'target reps');

    final plans = await restored.watchAllPlans().first;
    final assignments =
        await restored.watchPlanWorkouts(plans.single.id).first;
    expect(plans.single.name, 'Winter');
    expect(assignments.single.weekday, 2);

    expect((await restored.watchDayNote('2026-01-01').first)?.note,
        'Felt strong');
    expect((await restored.watchBodyWeights().first).single.kg, 71.5);

    final links = await restored.watchInspirations().first;
    expect(links.single.title, 'Hangboard basics');
    expect(links.single.notes, 'good protocol');
    expect(links.single.categoryId, hang.id,
        reason: 'stays filed under its exercise');
  });

  test('re-importing the same backup adds nothing', () async {
    await seed(source);
    final json = await source.exportToJson();

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    final first = await restored.importFromJson(json);
    final second = await restored.importFromJson(json);

    expect(first, 2, reason: 'both sets land the first time');
    expect(second, 0, reason: 'nothing new the second time');
    expect(await restored.watchAllWorkouts().first, hasLength(1));
    expect(await restored.watchAllPlans().first, hasLength(1));
    expect(await restored.watchInspirations().first, hasLength(1));
  });

  test('importing into a database that already has the data is a no-op',
      () async {
    await seed(source);
    final json = await source.exportToJson();

    final hangId = (await source.watchAllCategories().first)
        .firstWhere((c) => c.name == 'Edge Lift 18 mm')
        .id;
    final before = await source.watchSetsForCategory(hangId).first;
    expect(await source.importFromJson(json), 0);
    final after = await source.watchSetsForCategory(hangId).first;
    expect(after.length, before.length);
    expect(await source.watchInspirations().first, hasLength(1));
  });

  test('reads a version 2 export, which had no inspirations', () async {
    await seed(source);
    final json = (await source.exportToJson())
        .replaceAll('"version": 3', '"version": 2');

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    await restored.importFromJson(json);

    expect(await restored.watchAllCategories().first, isNotEmpty);
  });
}
