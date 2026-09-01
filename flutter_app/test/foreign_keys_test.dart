import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

/// Foreign keys are enforced from v16 on, so every write path has to keep its
/// references honest. This walks the ones the app actually uses.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('main write paths survive foreign key enforcement', () async {
    final bench = await db.insertOrGetCategory('Bench');
    final squat = await db.insertOrGetCategory('Squat');
    await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: bench, dateStr: '2026-01-01', timestamp: 1, reps: const Value(5)));
    await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: squat, dateStr: '2026-01-01', timestamp: 2, reps: const Value(5)));

    final w = await db.insertWorkout('Push');
    await db.addExerciseToWorkout(w, bench);
    await db.addExerciseToWorkout(w, squat);
    final dup = await db.duplicateWorkout(w, newName: 'Push copy');
    final fromDay = await db.createWorkoutFromDay('2026-01-01', 'Day copy');

    final p = await db.insertPlan('Week');
    await db.assignWorkoutToPlan(p, w, weekday: 1);
    await db.assignWorkoutToPlan(p, dup, dateStr: '2026-01-02');
    await db.shiftPlanWeekFrom(p, 1);

    final planJson = await db.exportPlanToJson(p);
    await db.importPlanFromJson(planJson);

    final full = await db.exportToJson();
    await db.importFromJson(full);

    await db.insertInspiration(title: 'x', url: 'u', categoryId: bench);
    await db.importFitNotes([
      {'Date': '2026-02-01', 'Exercise': 'Row', 'Weight': '50', 'Reps': '5'},
    ]);

    await db.deleteWorkout(fromDay);
    await db.deleteWorkout(dup);
    await db.deletePlan(p);
    await db.deleteCategory(bench);
    await db.deleteCategory(squat);
    final cats = await db.watchAllCategories().first;
    for (final c in cats) {
      await db.deleteCategory(c.id);
    }
    for (final wo in await db.watchAllWorkouts().first) {
      await db.deleteWorkout(wo.id);
    }
    for (final pl in await db.watchAllPlans().first) {
      await db.deletePlan(pl.id);
    }
    expect(await db.watchAllCategories().first, isEmpty);
  });
}
