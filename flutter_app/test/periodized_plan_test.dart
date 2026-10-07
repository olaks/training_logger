import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/format_utils.dart';

/// Building and running a periodized plan through the database. Where the
/// plan stands is replayed by `utils/periodization.dart` (tested on its own);
/// these check that the right rows feed it.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// A plan with one phase rotating through two new workouts.
  Future<({int plan, int phase, int a, int b})> capacityPlan(
      {int passes = 10, int? deloadEvery}) async {
    final plan = await db.insertPlan('Season');
    final phase = await db.insertPhase(plan, 'Capacity',
        lengthPasses: passes, deloadEvery: deloadEvery);
    final a = await db.insertWorkout('Strength A');
    final b = await db.insertWorkout('Board');
    await db.addSessionToPhase(phase, a);
    await db.addSessionToPhase(phase, b);
    return (plan: plan, phase: phase, a: a, b: b);
  }

  test('a new periodized plan starts at the first pass of its first phase',
      () async {
    final p = await capacityPlan();
    await db.insertPhase(p.plan, 'Basic strength', lengthPasses: 8);

    final active = await db.activePlan();
    expect(active?.plan.id, p.plan);
    expect(active?.state.phase?.name, 'Capacity');
    expect(active?.state.pass, 1);
    expect(active?.state.remaining, [p.a, p.b]);
  });

  test('a plan without phases is not a periodized plan', () async {
    await db.insertPlan('Week');

    expect(await db.activePlan(), isNull);
  });

  group('running the plan', () {
    test('finishing a session in the current pass ticks it off', () async {
      final p = await capacityPlan();

      final event = await db.finishSession(p.b, '2026-03-02');

      expect(event, isNotNull);
      expect((await db.activePlan())!.state.remaining, [p.a]);
    });

    test('finishing a workout that is not due this pass records nothing',
        () async {
      final p = await capacityPlan();
      final other = await db.insertWorkout('Mobility');
      await db.finishSession(p.a, '2026-03-02');

      expect(await db.finishSession(other, '2026-03-02'), isNull);
      expect(await db.finishSession(p.a, '2026-03-03'), isNull,
          reason: 'it was already done this pass');
      expect((await db.activePlan())!.events, hasLength(1));
    });

    test('finishing with no periodized plan running records nothing',
        () async {
      final w = await db.insertWorkout('Push');

      expect(await db.finishSession(w, '2026-03-02'), isNull);
    });

    test('skipping a session lets the pass finish without it', () async {
      final p = await capacityPlan();
      await db.finishSession(p.a, '2026-03-02');
      await db.skipSession(p.b, '2026-03-03');

      final state = (await db.activePlan())!.state;
      expect(state.pass, 2);
      expect(state.remaining, [p.a, p.b]);
    });

    test('deload now turns the coming pass into a deload', () async {
      await capacityPlan();
      await db.deloadNow('2026-03-02');

      expect((await db.activePlan())!.state.isDeload, isTrue);
    });

    test('moving on starts the next phase', () async {
      final p = await capacityPlan();
      await db.insertPhase(p.plan, 'Basic strength', lengthPasses: 8);
      await db.advancePhase('2026-03-02');

      expect((await db.activePlan())!.state.phase?.name, 'Basic strength');
    });

    test('moving on from the last phase stops the plan, so the next one '
        'can run', () async {
      final p = await capacityPlan();
      await db.advancePhase('2026-03-02');

      expect(await db.activePlan(), isNull);
      final plan = (await db.watchAllPlans().first).single;
      expect(plan.active, isFalse);

      final next = await capacityPlan();
      expect((await db.activePlan())?.plan.id, next.plan,
          reason: 'nothing is running, so the new plan starts at once');
      expect(p.plan, isNot(next.plan));
    });

    test('an event can be undone', () async {
      final p = await capacityPlan();
      final event = await db.finishSession(p.a, '2026-03-02');

      await db.deletePlanEvent(event!.id);
      expect((await db.activePlan())!.state.remaining, [p.a, p.b]);

      await db.restorePlanEvent(event);
      expect((await db.activePlan())!.state.remaining, [p.b]);
    });

    test('the plan state is pushed again when a session is finished',
        () async {
      final p = await capacityPlan();
      final states = db.watchActivePlan().map((a) => a?.state.remaining);

      final seen = states.take(2).toList();
      await Future<void>.delayed(Duration.zero);
      await db.finishSession(p.a, '2026-03-02');

      expect((await seen).last, [p.b]);
    });
  });

  group('active plans', () {
    test('starting a periodized plan stops the one that was running',
        () async {
      final first = await capacityPlan();
      final second = await capacityPlan();
      await db.setPlanActive(second.plan, true);

      expect((await db.activePlan())?.plan.id, second.plan);
      final plans = await db.watchAllPlans().first;
      expect(plans.firstWhere((p) => p.id == first.plan).active, isFalse);
    });

    test('a periodized plan built while another runs waits to be started',
        () async {
      final running = await capacityPlan();
      await capacityPlan();

      expect((await db.activePlan())?.plan.id, running.plan);
    });

    test('weekly plans keep running alongside a periodized plan', () async {
      await capacityPlan();
      final week = await db.insertPlan('Week');
      await db.setPlanActive(week, true);

      final plans = await db.watchAllPlans().first;
      expect(plans.where((p) => p.active), hasLength(2));
    });

    test('an inactive weekly plan schedules nothing', () async {
      final week = await db.insertPlan('Week');
      final w = await db.insertWorkout('Push');
      await db.addExerciseToWorkout(w, await db.insertOrGetCategory('Bench'));
      await db.assignWorkoutToPlan(week, w, weekday: 1); // 2026-03-02 is a Monday
      expect(await db.watchPlannedWorkoutsForDate('2026-03-02').first,
          hasLength(1));

      await db.setPlanActive(week, false);

      expect(await db.watchPlannedWorkoutsForDate('2026-03-02').first, isEmpty);
      expect(await db.watchPlannedCategoryIdsForDate('2026-03-02').first,
          isEmpty);
    });

    test('a periodized plan schedules by rotation, not by weekday', () async {
      final p = await capacityPlan();
      final w = await db.insertWorkout('Push');
      await db.addExerciseToWorkout(w, await db.insertOrGetCategory('Bench'));
      await db.assignWorkoutToPlan(p.plan, w, weekday: 1);

      expect(await db.watchPlannedWorkoutsForDate('2026-03-02').first, isEmpty);
    });
  });

  group('targets', () {
    final today = dateStrFrom(DateTime.now());

    /// Bench in workout [w] at 4×6 @ RPE 8.
    Future<int> benchIn(int w) async {
      final bench = await db.insertOrGetCategory('Bench');
      await db.addExerciseToWorkout(w, bench);
      final we = (await db.watchExercisesForWorkout(w).first)
          .firstWhere((r) => r.$2.id == bench)
          .$1;
      await db.updateWorkoutTarget(we, 4, 6);
      await db.updateWorkoutTargetRpe(we, 8);
      return bench;
    }

    test('a workout carries a target RPE per exercise', () async {
      final w = await db.insertWorkout('Push');
      await benchIn(w);

      expect((await db.watchExercisesForWorkout(w).first).single.$5, 8);
    });

    test('setting the sets and reps target leaves the RPE alone', () async {
      final w = await db.insertWorkout('Push');
      await benchIn(w);
      final we = (await db.watchExercisesForWorkout(w).first).single.$1;
      await db.updateWorkoutTarget(we, 5, 5);

      expect((await db.watchExercisesForWorkout(w).first).single.$5, 8);
    });

    test('a copied workout keeps its target RPEs', () async {
      final w = await db.insertWorkout('Push');
      await benchIn(w);
      final copy = await db.duplicateWorkout(w);

      expect((await db.watchExercisesForWorkout(copy).first).single.$5, 8);
    });

    test("a weekly plan's exercise target includes the RPE", () async {
      final w = await db.insertWorkout('Push');
      final bench = await benchIn(w);
      final week = await db.insertPlan('Week');
      await db.assignWorkoutToPlan(week, w, weekday: 1);

      final t = await db.watchExerciseTarget(bench, '2026-03-02').first;
      expect((t?.sets, t?.reps, t?.rpe, t?.isDeload), (4, 6, 8, false));
      expect(await db.watchExerciseTarget(bench, '2026-03-03').first, isNull,
          reason: 'Tuesday has nothing planned');
    });

    test("the running phase overrides the workout's RPE", () async {
      final p = await capacityPlan();
      final bench = await benchIn(p.a);
      await db.setPhaseExerciseTarget(p.phase, bench, rpe: 7);

      final t = await db.watchExerciseTarget(bench, today).first;
      expect((t?.sets, t?.reps, t?.rpe), (4, 6, 7));
    });

    test('a deload pass drops the target to RPE 5', () async {
      final p = await capacityPlan();
      final bench = await benchIn(p.a);
      await db.setPhaseExerciseTarget(p.phase, bench, rpe: 9);
      await db.deloadNow(today);

      final t = await db.watchExerciseTarget(bench, today).first;
      expect((t?.rpe, t?.isDeload), (5, true));
    });

    test('a phase override with nothing set is removed', () async {
      final p = await capacityPlan();
      final bench = await benchIn(p.a);
      await db.setPhaseExerciseTarget(p.phase, bench, rpe: 7, sets: 3);
      expect(await db.watchPhaseExerciseTargets(p.phase).first, hasLength(1));

      await db.setPhaseExerciseTarget(p.phase, bench);

      expect(await db.watchPhaseExerciseTargets(p.phase).first, isEmpty);
    });

    test('a past day shows the target as it stood that day', () async {
      final p = await capacityPlan();
      final bench = await benchIn(p.a);
      await db.setPhaseExerciseTarget(p.phase, bench, rpe: 7);
      // The first week is done that day; the week after is a deload.
      await db.finishSession(p.a, '2026-03-02');
      await db.finishSession(p.b, '2026-03-02');
      await db.deloadNow(today);

      final then = await db.watchExerciseTarget(bench, '2026-03-02').first;
      expect((then?.rpe, then?.isDeload), (7, false),
          reason: 'the deload came after');
      final now = await db.watchExerciseTarget(bench, today).first;
      expect((now?.rpe, now?.isDeload), (5, true));
    });

    test('a past day the plan has no session on has no periodized target',
        () async {
      final p = await capacityPlan();
      final bench = await benchIn(p.a);
      await db.finishSession(p.a, '2026-03-02');

      expect(await db.watchExerciseTarget(bench, '2026-03-01').first, isNull);
    });

    test('an exercise outside the running phase has no periodized target',
        () async {
      await capacityPlan();
      final other = await db.insertWorkout('Legs');
      final bench = await benchIn(other);

      expect(await db.watchExerciseTarget(bench, today).first, isNull);
    });
  });

  group('deleting and undoing', () {
    /// A running plan with a session done, a deload and a phase override.
    Future<({int plan, int phase, int a, int b, int bench})> usedPlan() async {
      final p = await capacityPlan(deloadEvery: 4);
      final bench = await db.insertOrGetCategory('Bench');
      await db.addExerciseToWorkout(p.a, bench);
      await db.setPhaseExerciseTarget(p.phase, bench, rpe: 7);
      await db.finishSession(p.a, '2026-03-02');
      await db.deloadNow('2026-03-02');
      return (plan: p.plan, phase: p.phase, a: p.a, b: p.b, bench: bench);
    }

    test('a deleted periodized plan comes back where it stood', () async {
      final p = await usedPlan();

      final deleted = await db.deletePlan(p.plan);
      expect(await db.activePlan(), isNull);

      await db.restorePlan(deleted!);
      final state = (await db.activePlan())!.state;
      expect(state.phase?.id, p.phase);
      expect(state.remaining, [p.b]);
      expect(await db.watchPhaseExerciseTargets(p.phase).first, hasLength(1));
    });

    test('a workout in a rotation can be deleted, and comes back in it',
        () async {
      final p = await usedPlan();
      await db.finishSession(p.b, '2026-03-03');
      await db.finishSession(p.a, '2026-03-04');
      expect((await db.activePlan())!.state.pass, 2);

      final deleted = await db.deleteWorkout(p.a);
      final without = (await db.activePlan())!;
      expect(without.rotations[p.phase], [p.b]);
      expect(without.state.pass, 2,
          reason: 'the week trained with it stays done');

      await db.restoreWorkout(deleted!);
      final active = (await db.activePlan())!;
      expect(active.rotations[p.phase], [p.a, p.b]);
      expect(active.state.remaining, [p.b],
          reason: 'the session done with it is back too');
      expect(active.events.where((e) => e.workoutId == p.a), hasLength(2));
    });

    test('an exercise with a phase override can be deleted, and the override '
        'comes back with it', () async {
      final p = await usedPlan();

      final deleted = await db.deleteCategory(p.bench);
      expect(await db.watchPhaseExerciseTargets(p.phase).first, isEmpty);

      await db.restoreCategory(deleted!);
      expect((await db.watchPhaseExerciseTargets(p.phase).first).single.targetRpe,
          7);
    });

    test('a deleted phase comes back with its rotation, overrides and log',
        () async {
      final p = await usedPlan();
      await db.insertPhase(p.plan, 'Basic strength', lengthPasses: 8);

      final deleted = await db.deletePhase(p.phase);
      expect((await db.activePlan())!.state.phase?.name, 'Basic strength');

      await db.restorePhase(deleted!);
      final state = (await db.activePlan())!.state;
      expect(state.phase?.id, p.phase);
      expect(state.remaining, [p.b]);
      expect(await db.watchPhaseExerciseTargets(p.phase).first, hasLength(1));
    });
  });

  group('editing phases', () {
    test('a phase can be renamed, resized and given a deload rule', () async {
      final p = await capacityPlan();
      await db.updatePhase(p.phase,
          name: 'Base', lengthPasses: 6, deloadEvery: 3);

      final phase = (await db.watchPlanPhases(p.plan).first).single;
      expect((phase.name, phase.lengthPasses, phase.deloadEvery),
          ('Base', 6, 3));
    });

    test('phases are listed, and run, in the order they are put in',
        () async {
      final p = await capacityPlan();
      final strength =
          await db.insertPhase(p.plan, 'Basic strength', lengthPasses: 8);
      await db.reorderPhases([strength, p.phase]);

      expect((await db.watchPlanPhases(p.plan).first).map((x) => x.id),
          [strength, p.phase]);
      expect((await db.activePlan())!.state.phase?.id, strength);
    });

    test('adding a session mid-plan keeps the weeks already done', () async {
      final p = await capacityPlan();
      await db.finishSession(p.a, '2026-03-02');
      await db.finishSession(p.b, '2026-03-03');
      await db.addSessionToPhase(p.phase, await db.insertWorkout('Legs'));

      expect((await db.activePlan())!.state.pass, 2);
    });

    test('a session can be taken out of a rotation', () async {
      final p = await capacityPlan();
      final sessions = await db.watchPlanSessions(p.plan).first;
      expect(sessions.map((s) => s.workoutId), [p.a, p.b]);

      await db.removePhaseSession(sessions.first.id);

      expect((await db.activePlan())!.rotations[p.phase], [p.b]);
    });
  });
}
