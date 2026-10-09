import 'dart:typed_data';

import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/periodization.dart';

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
        (await db.watchExercisesForWorkout(workout).first).first.id, 4, 6);

    final plan = await db.insertPlan('Winter');
    await db.assignWorkoutToPlan(plan, workout, weekday: 2);

    await db.setCategoryImage(hang, Uint8List.fromList([9, 8, 7]));

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
    expect(members.map((m) => m.category.name), ['Edge Lift 18 mm', 'Comp Boulder']);
    expect(members.first.target.sets, 4, reason: 'target sets');
    expect(members.first.target.reps, 6, reason: 'target reps');

    final plans = await restored.watchAllPlans().first;
    final assignments =
        await restored.watchPlanWorkouts(plans.single.id).first;
    expect(plans.single.name, 'Winter');
    expect(assignments.single.weekday, 2);

    expect((await restored.watchDayNote('2026-01-01').first)?.note,
        'Felt strong');
    expect((await restored.watchBodyWeights().first).single.kg, 71.5);

    expect(await restored.getCategoryImage(hang.id), [9, 8, 7],
        reason: 'the exercise photo travels with the backup');

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

  test('an exercise logged under a different capitalisation merges into the '
      'one already here', () async {
    await seed(source);
    final json = await source.exportToJson();

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    // Same exercise, typed differently — a case-sensitive match used to fork
    // its history into a second exercise of nearly the same name.
    final existing = await restored.insertOrGetCategory('edge lift 18 MM');
    await restored.importFromJson(json);

    final names = (await restored.watchAllCategories().first)
        .map((c) => c.name.toLowerCase())
        .where((n) => n == 'edge lift 18 mm');
    expect(names, hasLength(1));
    expect(await restored.watchSetsForCategory(existing).first, hasLength(1),
        reason: 'the imported set lands on the exercise already here');
  });

  test('a backup still imports when two exercises share a name', () async {
    await seed(source);
    final json = await source.exportToJson();

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    // Only reachable by writing straight to the table — which is what the
    // schema allows, and what the import has to survive.
    await restored.insertCategory('Edge Lift 18 mm');
    await restored.insertCategory('Edge Lift 18 mm');

    expect(await restored.importFromJson(json), 2);
  });

  group('periodized plans', () {
    /// A running plan two sessions in, with a deload queued and an override.
    Future<void> seedPeriodized(AppDatabase db) async {
      final bench = await db.insertOrGetCategory('Bench');
      final a = await db.insertWorkout('Strength A');
      await db.addExerciseToWorkout(a, bench);
      final we = (await db.watchExercisesForWorkout(a).first).single.id;
      await db.updateWorkoutTarget(we, 4, 6);
      await db.updateWorkoutTargetRpe(we, 8);
      final b = await db.insertWorkout('Board');
      await db.addExerciseToWorkout(
          b, await db.insertOrGetCategory('Board climbing'));

      final plan = await db.insertPlan('Season');
      final capacity = await db.insertPhase(plan, 'Capacity',
          lengthPasses: 10, deloadEvery: 4);
      // An 8-day cycle: A on day 1, B on day 2, rest after.
      await db.addSessionToPhase(capacity, a, day: 1);
      await db.addSessionToPhase(capacity, b, day: 2);
      await db.setPhaseExerciseTarget(
          capacity, bench, const Target(rpe: 7, reps: 10));
      final strength =
          await db.insertPhase(plan, 'Basic strength', lengthPasses: 8);
      await db.addSessionToPhase(strength, a, day: 1);

      await db.finishSession(a, '2026-03-02');
      await db.finishSession(b, '2026-03-04');
      await db.finishSession(a, '2026-03-09');
      await db.deloadNow('2026-03-09');
    }

    test('a running plan comes back where it stood', () async {
      await seedPeriodized(source);
      final before = (await source.activePlan())!.state;

      final restored = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(restored.close);
      await restored.importFromJson(await source.exportToJson());

      final active = (await restored.activePlan())!;
      expect(active.plan.name, 'Season');
      expect(active.phases.map((p) => (p.name, p.lengthPasses, p.deloadEvery)),
          [('Capacity', 10, 4), ('Basic strength', 8, null)]);
      expect(active.plan.cycleDays, 8);
      final days = {
        for (final s in await restored.watchPlanSessions(active.plan.id).first)
          if (s.phaseId == active.phases.first.id) s.workoutId: s.day,
      };
      expect(days.values.toList()..sort(), [1, 2],
          reason: 'each workout keeps its day of the cycle');
      final s = active.state;
      expect((s.phase?.name, s.pass, s.day, s.isDeload, s.totalPasses),
          (before.phase?.name, before.pass, before.day, before.isDeload,
              before.totalPasses));
      expect(s.remaining.length, before.remaining.length);

      final workouts = await restored.watchAllWorkouts().first;
      final a = workouts.firstWhere((w) => w.name == 'Strength A');
      expect((await restored.watchExercisesForWorkout(a.id).first).single.target.rpe, 8,
          reason: 'the target RPE travels with the workout');
      final override = (await restored
              .watchPhaseExerciseTargets(active.phases.first.id)
              .first)
          .single;
      expect((override.targetRpe, override.targetReps), (7, 10));
    });

    test('re-importing the backup adds no second copy of the plan', () async {
      await seedPeriodized(source);
      final json = await source.exportToJson();

      final restored = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(restored.close);
      await restored.importFromJson(json);
      await restored.importFromJson(json);

      final active = (await restored.activePlan())!;
      expect(active.phases, hasLength(2));
      expect(active.events, hasLength(4));
      expect(active.rotations[active.phases.first.id], hasLength(2));
    });

    test('an imported running plan waits while another runs', () async {
      await seedPeriodized(source);
      final json = await source.exportToJson();

      final restored = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(restored.close);
      final mine = await restored.insertPlan('Mine');
      final w = await restored.insertWorkout('Push');
      await restored.addSessionToPhase(
          await restored.insertPhase(mine, 'Base', lengthPasses: 4), w,
          day: 1);
      await restored.importFromJson(json);

      expect((await restored.activePlan())?.plan.id, mine);
    });

    test('a shared plan imported over one in progress lands beside it',
        () async {
      await seedPeriodized(source);
      final running = (await source.activePlan())!;
      final json = await source.exportPlanToJson(running.plan.id);

      await source.importPlanFromJson(json);

      final plans = await source.watchAllPlans().first;
      expect(plans.map((p) => p.name), unorderedEquals(['Season', 'Season 2']));
      final after = (await source.activePlan())!;
      expect(after.plan.id, running.plan.id, reason: 'the running plan runs on');
      expect(after.events, hasLength(running.events.length),
          reason: 'none of its progress is lost');
      expect(after.state.pass, running.state.pass);
    });

    test('a shared plan imported over an unstarted one replaces its phases',
        () async {
      final plan = await source.insertPlan('Season');
      await source.insertPhase(plan, 'Old', lengthPasses: 3);
      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await seedPeriodized(other);
      final json =
          await other.exportPlanToJson((await other.activePlan())!.plan.id);

      await source.importPlanFromJson(json);

      expect(await source.watchAllPlans().first, hasLength(1));
      expect((await source.watchPlanPhases(plan).first).map((p) => p.name),
          ['Capacity', 'Basic strength']);
    });

    test('a long plan log imports in no more statements than a short one',
        () async {
      /// Statements a backup import runs, for a plan [weeks] passes in.
      Future<int> statementsFor(int weeks) async {
        final from = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(from.close);
        final plan = await from.insertPlan('Season');
        await from.setCycleDays(plan, 1);
        final phase =
            await from.insertPhase(plan, 'Capacity', lengthPasses: 40);
        final ws = [
          for (final name in ['A', 'B', 'C'])
            await from.insertWorkout(name),
        ];
        for (final w in ws) {
          await from.addSessionToPhase(phase, w, day: 1);
        }
        for (var i = 0; i < weeks; i++) {
          for (final w in ws) {
            await from.finishSession(w, '2026-03-02');
          }
        }

        final counter = _StatementCounter();
        final into = AppDatabase.forTesting(
            NativeDatabase.memory().interceptWith(counter));
        addTearDown(into.close);
        await into.insertPlan('warm up the connection');
        counter.count = 0;
        await into.importFromJson(await from.exportToJson());
        return counter.count;
      }

      expect(await statementsFor(20), await statementsFor(2),
          reason: 'the log is written in one go, not a statement per entry');
    });

    test('a shared plan matches workouts and plans whatever their case',
        () async {
      final plan = await source.insertPlan('season');
      final mine = await source.insertWorkout('strength a');
      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await seedPeriodized(other);
      final json =
          await other.exportPlanToJson((await other.activePlan())!.plan.id);

      await source.importPlanFromJson(json);

      expect(await source.watchAllPlans().first, hasLength(1),
          reason: '"Season" is the plan already here as "season"');
      final workouts = await source.watchAllWorkouts().first;
      expect(workouts.where((w) => w.name.toLowerCase() == 'strength a'),
          hasLength(1));
      final sessions = await source.watchPlanSessions(plan).first;
      expect(sessions.map((s) => s.workoutId), contains(mine));
    });

    test('a shared plan carries its phases and targets but not the progress',
        () async {
      await seedPeriodized(source);
      final planId = (await source.activePlan())!.plan.id;
      final json = await source.exportPlanToJson(planId);

      final restored = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(restored.close);
      await restored.importPlanFromJson(json);

      final active = (await restored.activePlan())!;
      expect(active.phases.map((p) => p.name), ['Capacity', 'Basic strength']);
      expect((active.state.pass, active.state.day), (1, 1),
          reason: 'it starts from the beginning');
      expect(active.events, isEmpty);
      expect(active.plan.cycleDays, 8, reason: 'the cycle travels with it');
      expect(active.state.remaining, hasLength(1),
          reason: 'only day 1 is due; the other workout is on day 2');
      final override = (await restored
              .watchPhaseExerciseTargets(active.phases.first.id)
              .first)
          .single;
      expect(override.targetRpe, 7);
      final a = (await restored.watchAllWorkouts().first)
          .firstWhere((w) => w.name == 'Strength A');
      expect((await restored.watchExercisesForWorkout(a.id).first).single.target.rpe, 8);
    });
  });
}

/// Counts every statement that reaches the database.
class _StatementCounter extends QueryInterceptor {
  var count = 0;

  @override
  Future<void> runBatched(QueryExecutor executor, statements) {
    count++;
    return super.runBatched(executor, statements);
  }

  @override
  Future<void> runCustom(QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runCustom(executor, statement, args);
  }

  @override
  Future<int> runInsert(QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runInsert(executor, statement, args);
  }

  @override
  Future<int> runUpdate(QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runUpdate(executor, statement, args);
  }

  @override
  Future<int> runDelete(QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runDelete(executor, statement, args);
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) {
    count++;
    return super.runSelect(executor, statement, args);
  }
}
