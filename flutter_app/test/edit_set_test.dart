import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

void main() {
  late AppDatabase db;
  late int catId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catId = await db.insertOrGetCategory('Dead Hang');
  });
  tearDown(() => db.close());

  Future<WorkoutSet> only() async =>
      (await db.watchSetsForCategory(catId).first).single;

  test('corrects the values of a logged set', () async {
    final id = await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 1,
      weightKg: const Value(20),
      timeSecs: const Value(10),
      rpe: const Value(8),
    ));

    await db.updateSet(id, weightKg: 25, timeSecs: 7, rpe: 9);

    final s = await only();
    expect(s.weightKg, 25);
    expect(s.timeSecs, 7);
    expect(s.rpe, 9);
    expect(s.dateStr, '2026-01-01', reason: 'the day it was logged is kept');
  });

  test('clears fields left empty instead of keeping the old value', () async {
    final id = await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 1,
      weightKg: const Value(20),
      reps: const Value(5),
      rpe: const Value(8),
    ));

    await db.updateSet(id, weightKg: 20);

    final s = await only();
    expect(s.weightKg, 20);
    expect(s.reps, isNull);
    expect(s.rpe, isNull);
  });

  test('keeps climbing details together', () async {
    final id = await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 1,
      grade: const Value('6C'),
      wallAngle: const Value(20),
      climbName: const Value('Blue arete'),
    ));

    await db.updateSet(id,
        grade: '7A', wallAngle: 30, climbName: 'Blue arete', rpe: 9);

    final s = await only();
    expect(s.grade, '7A');
    expect(s.wallAngle, 30);
    expect(s.climbName, 'Blue arete');
    expect(s.rpe, 9);
  });

  test('leaves other sets alone', () async {
    final first = await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 1,
      reps: const Value(5),
    ));
    await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 2,
      reps: const Value(8),
    ));

    await db.updateSet(first, reps: 6);

    final sets = await db.watchSetsForCategory(catId).first;
    expect(sets.map((s) => s.reps).toList()..sort(), [6, 8]);
  });
}
