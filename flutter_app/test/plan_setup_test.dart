import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/format_utils.dart';
import 'package:training_logger/utils/periodization.dart';
import 'package:training_logger/utils/plan_setup.dart';

/// The setup guide's draft of a plan, and writing it back. The guide loads
/// the plan as it stands, so these check that a round trip through it
/// changes only what was edited — above all that a phase in progress keeps
/// its log.
void main() {
  late AppDatabase db;
  late int plan, climbing, bench, legs;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    plan = await db.insertPlan('Year');
    climbing = await db.insertWorkout('Climbing');
    bench = await db.insertWorkout('Bench press');
    legs = await db.insertWorkout('Legs');
  });
  tearDown(() => db.close());

  Future<PlanSetup> load() async => PlanSetup.fromPlan(
        (await db.watchAllPlans().first).firstWhere((p) => p.id == plan),
        await db.watchPlanPhases(plan).first,
        await db.watchPlanSessions(plan).first,
      );

  Future<Cycle> cycleOfPhase(int phaseId) async => cyclesOf(
        await db.watchPlanPhases(plan).first,
        await db.watchPlanSessions(plan).first,
      )[phaseId]!;

  group('loading a plan', () {
    test('a plan without phases starts from the classic year', () async {
      final setup = await load();

      expect(setup.phases.map((p) => p.name),
          ['Capacity', 'Basic strength', 'Max strength', 'Peak']);
      expect(setup.template, isEmpty);
      expect(setup.cycleDays, 8);
    });

    test('the first phase is the template, and only a phase that differs '
        'gets its own cycle', () async {
      final first = await db.insertPhase(plan, 'Base', lengthPasses: 4);
      final same = await db.insertPhase(plan, 'Build', lengthPasses: 4);
      final other = await db.insertPhase(plan, 'Peak', lengthPasses: 2);
      for (final p in [first, same]) {
        await db.addSessionToPhase(p, climbing, day: 1);
        await db.addSessionToPhase(p, bench, day: 1);
        await db.addSessionToPhase(p, legs, day: 3);
      }
      await db.addSessionToPhase(other, climbing, day: 2);

      final setup = await load();

      expect(setup.template, {
        1: [climbing, bench],
        3: [legs],
      });
      expect(setup.phases.map((p) => p.own == null), [true, true, false]);
      expect(setup.cycleOf(setup.phases[2]), {
        2: [climbing],
      });
    });
  });

  group('applying it', () {
    test('writes the year: cycle length, phases in order, every cycle',
        () async {
      final setup = await load()
        ..cycleDays = 7
        ..template = {
          1: [climbing, bench],
          4: [legs],
        };
      setup.phases.last.own = {
        1: [climbing],
      };

      await db.applyPlanSetup(plan, setup);

      final p = (await db.watchAllPlans().first).single;
      expect(p.cycleDays, 7);
      final phases = await db.watchPlanPhases(plan).first;
      expect(phases.map((p) => (p.name, p.lengthPasses, p.deloadEvery)), [
        ('Capacity', 8, 4),
        ('Basic strength', 10, 4),
        ('Max strength', 8, 3),
        ('Peak', 4, null),
      ]);
      expect(await cycleOfPhase(phases.first.id), {
        1: [climbing, bench],
        4: [legs],
      });
      expect(await cycleOfPhase(phases.last.id), {
        1: [climbing],
      });
      expect((await db.activePlan())?.plan.id, plan,
          reason: 'its first phases make it the running plan');
    });

    test('a phase in progress keeps its log through a rename and a move',
        () async {
      final base = await db.insertPhase(plan, 'Base', lengthPasses: 4);
      final peak = await db.insertPhase(plan, 'Peak', lengthPasses: 2);
      await db.addSessionToPhase(base, climbing, day: 1);
      await db.addSessionToPhase(peak, bench, day: 1);
      await db.finishSession(climbing, dateStrFrom(DateTime.now()));

      final setup = await load();
      final draft = setup.phases.first..name = 'Capacity';
      setup.phases
        ..removeAt(0)
        ..add(draft);
      final removed = await db.applyPlanSetup(plan, setup);

      expect(removed, isEmpty);
      final phases = await db.watchPlanPhases(plan).first;
      expect(phases.map((p) => (p.id, p.name)), [(peak, 'Peak'), (base, 'Capacity')]);
      expect((await db.watchPlanEvents(plan).first).single.phaseId, base);
    });

    test('a phase dropped from the setup goes, with its log, and comes back '
        'from its snapshot', () async {
      final base = await db.insertPhase(plan, 'Base', lengthPasses: 4);
      await db.insertPhase(plan, 'Peak', lengthPasses: 2);
      await db.addSessionToPhase(base, climbing, day: 1);
      await db.finishSession(climbing, dateStrFrom(DateTime.now()));

      final setup = await load();
      setup.phases.removeAt(0);
      final removed = await db.applyPlanSetup(plan, setup);

      expect(removed.map((d) => (d.phase.name, d.events.length)),
          [('Base', 1)]);
      expect((await db.watchPlanPhases(plan).first).map((p) => p.name),
          ['Peak']);

      await db.restorePhase(removed.single);
      expect(await db.watchPlanEvents(plan).first, hasLength(1));
    });

    test('days past a shortened cycle are left out', () async {
      final setup = await load()
        ..template = {
          1: [climbing],
          8: [legs],
        }
        ..cycleDays = 7;

      await db.applyPlanSetup(plan, setup);

      final days =
          (await db.watchPlanSessions(plan).first).map((s) => s.day).toSet();
      expect(days, {1});
    });
  });
}
