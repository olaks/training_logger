import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addSet(int catId, String date,
      {int? reps, double? weight, int ts = 0}) =>
      db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr:    date,
        timestamp:  ts,
        reps:       Value(reps),
        weightKg:   Value(weight),
      ));

  group('createWorkoutFromDay', () {
    test('one entry per exercise, in logged order, with targets', () async {
      final bench   = await db.insertOrGetCategory('Bench');
      final squat   = await db.insertOrGetCategory('Squat');

      await addSet(bench, '2026-08-30', reps: 5, weight: 60, ts: 100);
      await addSet(squat, '2026-08-30', reps: 8, weight: 80, ts: 200);
      await addSet(bench, '2026-08-30', reps: 5, weight: 62, ts: 300);
      await addSet(bench, '2026-08-30', reps: 5, weight: 64, ts: 400);
      // Different day — must be ignored.
      await addSet(squat, '2026-08-29', reps: 3, ts: 500);

      final wId = await db.createWorkoutFromDay('2026-08-30', 'Fri session');
      final rows = await db.watchExercisesForWorkout(wId).first;

      expect(rows.map((r) => r.$2.name), ['Bench', 'Squat']);
      expect(rows[0].$3, 3);  // three bench sets
      expect(rows[0].$4, 5);  // all at 5 reps
      expect(rows[1].$3, 1);
      expect(rows[1].$4, 8);
    });

    test('reps target is null when the sets disagree', () async {
      final rows0 = await db.insertOrGetCategory('Pull-ups');
      await addSet(rows0, '2026-08-30', reps: 8, ts: 100);
      await addSet(rows0, '2026-08-30', reps: 6, ts: 200);

      final wId = await db.createWorkoutFromDay('2026-08-30', 'Pull day');
      final rows = await db.watchExercisesForWorkout(wId).first;

      expect(rows.single.$3, 2);
      expect(rows.single.$4, isNull);
    });

    test('throws on a day with nothing logged', () {
      expect(() => db.createWorkoutFromDay('2026-01-01', 'Empty'),
          throwsStateError);
    });
  });

  group('duplicateWorkout', () {
    test('copies notes, exercises, targets and order', () async {
      final a = await db.insertOrGetCategory('A');
      final b = await db.insertOrGetCategory('B');

      final srcId = await db.insertWorkout('Push Day');
      await db.updateWorkoutNotes(srcId, 'warm up first');
      await db.addExerciseToWorkout(srcId, b);
      await db.addExerciseToWorkout(srcId, a);
      final srcRows = await db.watchExercisesForWorkout(srcId).first;
      await db.updateWorkoutTarget(srcRows.first.$1, 4, 10);

      final copyId = await db.duplicateWorkout(srcId);
      final copy = await db.watchAllWorkouts().first
          .then((ws) => ws.firstWhere((w) => w.id == copyId));
      final copyRows = await db.watchExercisesForWorkout(copyId).first;

      expect(copy.name, 'Push Day (copy)');
      expect(copy.notes, 'warm up first');
      expect(copyRows.map((r) => r.$2.name), ['B', 'A']); // order preserved
      expect(copyRows.first.$3, 4);
      expect(copyRows.first.$4, 10);
      // The original is untouched.
      expect((await db.watchExercisesForWorkout(srcId).first).length, 2);
    });

    test('honours an explicit name and de-dupes the default', () async {
      final srcId = await db.insertWorkout('Legs');
      await db.duplicateWorkout(srcId);                       // Legs (copy)
      final third = await db.duplicateWorkout(srcId);         // Legs (copy) 2
      final named =
          await db.duplicateWorkout(srcId, newName: '  Legs B  ');

      final names = (await db.watchAllWorkouts().first)
          .where((w) => w.id == third || w.id == named)
          .map((w) => w.name)
          .toSet();
      expect(names, {'Legs (copy) 2', 'Legs B'});
    });
  });
}
