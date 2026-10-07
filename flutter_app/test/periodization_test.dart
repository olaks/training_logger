import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/periodization.dart';

// Workouts in the rotations below.
const a = 1, b = 2, c = 3, d = 4;

PlanPhase phase(int id, {int passes = 10, int? deloadEvery, int order = 0}) =>
    PlanPhase(
      id: id,
      planId: 1,
      sortOrder: order,
      name: 'Phase $id',
      lengthPasses: passes,
      deloadEvery: deloadEvery,
    );

/// Builds events in the order given, one millisecond apart.
///
/// Sessions are stamped with [pass], the week they were recorded in, the way
/// the database stamps them. It only moves on through [passes] and [nextPass],
/// and starts over when a phase is moved on from.
class Log {
  final events = <PlanEvent>[];
  var pass = 1;

  void _add(int phaseId, PlanEventKind kind,
          [int? workoutId, bool closes = false]) =>
      events.add(PlanEvent(
        id: events.length + 1,
        planId: 1,
        phaseId: phaseId,
        workoutId: workoutId,
        pass: workoutId == null ? null : pass,
        closesPass: closes,
        dateStr: '2026-01-01',
        timestamp: events.length,
        kind: kind,
      ));

  void nextPass() => pass++;

  void done(int phaseId, List<int> workouts) {
    for (final w in workouts) {
      _add(phaseId, PlanEventKind.done, w);
    }
  }

  void skip(int phaseId, int workout) =>
      _add(phaseId, PlanEventKind.skip, workout);

  void deload(int phaseId) => _add(phaseId, PlanEventKind.deload);

  void advance(int phaseId) {
    _add(phaseId, PlanEventKind.advance);
    pass = 1;
  }

  /// [passes] full passes through [rotation], the last session of each
  /// marked as finishing it, as the database marks it.
  void passes(int phaseId, List<int> rotation, int passes) {
    for (var i = 0; i < passes; i++) {
      done(phaseId, rotation.sublist(0, rotation.length - 1));
      _add(phaseId, PlanEventKind.done, rotation.last, true);
      nextPass();
    }
  }
}

void main() {
  group('resolvePlan', () {
    test('a plan with no events is at the start of its first phase', () {
      final state = resolvePlan(
        [phase(10), phase(20, order: 1)],
        {10: [a, b, c], 20: [d]},
        const [],
      );

      expect(state.phase?.id, 10);
      expect(state.pass, 1);
      expect(state.totalPasses, 10);
      expect(state.remaining, [a, b, c]);
      expect(state.isDeload, isFalse);
      expect(state.phaseComplete, isFalse);
      expect(state.planComplete, isFalse);
    });

    test('sessions in a pass can be done in any order', () {
      final log = Log()..done(10, [c, a]);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 1);
      expect(state.remaining, [b]);
    });

    test('doing every session of the rotation starts the next pass', () {
      final log = Log()..done(10, [b, c, a]);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
      expect(state.remaining, [a, b, c]);
    });

    test('a skipped session counts towards finishing the pass', () {
      final log = Log()
        ..done(10, [a, c])
        ..skip(10, b);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
    });

    test('repeating a session already done this pass does not finish it', () {
      final log = Log()..done(10, [a, a, b, b]);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 1);
      expect(state.remaining, [c]);
    });

    test('a session outside the rotation is ignored', () {
      final log = Log()..done(10, [d]);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.remaining, [a, b, c]);
    });

    test('a finished phase waits on its last pass for the athlete to move on',
        () {
      final log = Log()..passes(10, [a, b], 3);
      final state = resolvePlan(
          [phase(10, passes: 3), phase(20, order: 1)],
          {10: [a, b], 20: [c]},
          log.events);

      expect(state.phase?.id, 10);
      expect(state.pass, 3);
      expect(state.phaseComplete, isTrue);
      expect(state.planComplete, isFalse);
    });

    test('moving on starts the next phase at its first pass', () {
      final log = Log()
        ..passes(10, [a, b], 3)
        ..advance(10)
        ..done(20, [c]);
      final state = resolvePlan(
          [phase(10, passes: 3), phase(20, order: 1)],
          {10: [a, b], 20: [c, d]},
          log.events);

      expect(state.phase?.id, 20);
      expect(state.pass, 1);
      expect(state.remaining, [d]);
      expect(state.phaseComplete, isFalse);
    });

    test('a phase can be moved on from early', () {
      final log = Log()
        ..done(10, [a])
        ..advance(10);
      final state = resolvePlan([phase(10), phase(20, order: 1)],
          {10: [a, b], 20: [c]}, log.events);

      expect(state.phase?.id, 20);
    });

    test('phases run in their sort order, not list order', () {
      final state = resolvePlan([phase(20, order: 1), phase(10)],
          {10: [a], 20: [b]}, const []);

      expect(state.phase?.id, 10);
    });

    test('moving on from the last phase ends the plan', () {
      final log = Log()
        ..passes(10, [a], 2)
        ..advance(10);
      final state =
          resolvePlan([phase(10, passes: 2)], {10: [a]}, log.events);

      expect(state.planComplete, isTrue);
      expect(state.phase, isNull);
    });

    test('a plan with no phases has nothing to do', () {
      final state = resolvePlan(const [], const {}, const []);

      expect(state.planComplete, isTrue);
      expect(state.phase, isNull);
      expect(state.remaining, isEmpty);
    });

    test('sessions done while a finished phase waits count once it is '
        'lengthened', () {
      final log = Log()..passes(10, [a, b], 3);

      expect(
          resolvePlan([phase(10, passes: 2)], {10: [a, b]}, log.events)
              .phaseComplete,
          isTrue);

      final extended =
          resolvePlan([phase(10, passes: 5)], {10: [a, b]}, log.events);
      expect(extended.pass, 4);
      expect(extended.phaseComplete, isFalse);
    });
  });

  group('editing a rotation mid-plan', () {
    test('adding a session keeps the weeks already done', () {
      final log = Log()
        ..passes(10, [a, b], 3)
        ..done(10, [a]);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 4);
      expect(state.remaining, [b, c],
          reason: 'the new session is due from the current week');
    });

    test('removing a session keeps the weeks already done', () {
      final log = Log()
        ..passes(10, [a, b, c], 2)
        ..done(10, [a]);
      final state = resolvePlan([phase(10)], {10: [a, b]}, log.events);

      expect(state.pass, 3);
      expect(state.remaining, [b]);
    });

    test('removing the only session left to do finishes the week', () {
      final log = Log()
        ..passes(10, [a, b], 2)
        ..done(10, [a]);
      final state = resolvePlan([phase(10)], {10: [a]}, log.events);

      expect(state.pass, 4);
      expect(state.remaining, [a]);
    });

    test('adding a session to a finished week leaves it finished', () {
      final log = Log()..passes(10, [a, b], 1);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
      expect(state.remaining, [a, b, c]);
    });

    test('undoing the session that finished a week reopens it, new session '
        'and all', () {
      final log = Log()..passes(10, [a, b], 1);
      final events = log.events.sublist(0, log.events.length - 1);
      final state = resolvePlan([phase(10)], {10: [a, b, c]}, events);

      expect(state.pass, 1);
      expect(state.remaining, [b, c]);
    });

    test('emptying the rotation keeps the weeks already done', () {
      final log = Log()..passes(10, [a, b], 2);
      final state = resolvePlan([phase(10)], {10: []}, log.events);

      expect(state.pass, 3);
    });

    test('a session whose workout is gone still marks its week', () {
      // Deleting a workout clears the event's workout but keeps its stamp.
      final log = Log()
        ..passes(10, [a, b], 2)
        ..done(10, [a]);
      final events = [
        for (final e in log.events)
          e.workoutId == a ? e.copyWith(workoutId: const Value(null)) : e,
      ];
      final state = resolvePlan([phase(10)], {10: [b]}, events);

      expect(state.pass, 3, reason: 'two weeks done, the third under way');
      expect(state.remaining, [b]);
    });

    test('undoing the session that started a week goes back to the one '
        'before', () {
      final log = Log()..passes(10, [a, b], 2);
      final events = log.events.sublist(0, log.events.length - 1);
      final state = resolvePlan([phase(10)], {10: [a, b]}, events);

      expect(state.pass, 2);
      expect(state.remaining, [b]);
    });
  });

  group('deloads', () {
    PlanState after(int passes, {int length = 10, int? every = 4,
        void Function(Log)? also}) {
      final log = Log()..passes(10, [a, b], passes);
      also?.call(log);
      return resolvePlan([phase(10, passes: length, deloadEvery: every)],
          {10: [a, b]}, log.events);
    }

    test('fall on every Nth pass, inside the phase length', () {
      final deloadPasses = [
        for (var done = 0; done < 10; done++)
          if (after(done).isDeload) after(done).pass,
      ];

      expect(deloadPasses, [4, 8]);
      expect(after(0).totalPasses, 10);
    });

    test('count down to the next one', () {
      expect(after(0).passesUntilDeload, 3);
      expect(after(2).passesUntilDeload, 1);
      expect(after(3).passesUntilDeload, 0);
      expect(after(4).passesUntilDeload, 3);
      expect(after(8).passesUntilDeload, isNull,
          reason: 'no deload is left in the phase');
    });

    test('a phase without a deload rule never deloads', () {
      expect(after(3, every: null).isDeload, isFalse);
      expect(after(0, every: null).passesUntilDeload, isNull);
    });

    test('deload now, between passes, makes the coming pass a deload', () {
      final state = after(0, also: (log) => log.deload(10));

      expect(state.pass, 1);
      expect(state.isDeload, isTrue);
    });

    test('deload now, mid-pass, makes the next pass the deload', () {
      final state = after(0, also: (log) => log
        ..done(10, [a])
        ..deload(10));
      expect(state.isDeload, isFalse);
      expect(state.passesUntilDeload, 1);

      final next = after(0, also: (log) => log
        ..done(10, [a])
        ..deload(10)
        ..done(10, [b]));
      expect(next.pass, 2);
      expect(next.isDeload, isTrue);
    });

    test('deload now replaces a scheduled deload up to two passes away', () {
      // Passes 1 done; deload now lands on pass 2, two before the one on 4.
      final state = after(1, also: (log) => log.deload(10));
      expect(state.isDeload, isTrue);
      expect(state.totalPasses, 10, reason: 'nothing was added');

      final later = after(1, also: (log) => log
        ..deload(10)
        ..passes(10, [a, b], 2));
      expect(later.pass, 4);
      expect(later.isDeload, isFalse,
          reason: 'the scheduled deload was taken early');
      expect(later.passesUntilDeload, 4,
          reason: 'the one on pass 8 still stands');
    });

    test('deload now further from a scheduled one is added, lengthening the '
        'phase and pushing later deloads back', () {
      // Deload now on pass 1, three before the scheduled one on 4.
      final state = after(0, also: (log) => log.deload(10));
      expect(state.totalPasses, 11);

      final later = after(0, also: (log) => log
        ..deload(10)
        ..passes(10, [a, b], 1));
      expect(later.pass, 2);
      expect(later.passesUntilDeload, 3,
          reason: 'the deload that was on pass 4 is now on pass 5');
    });

    test('deload now on a pass that is already a deload changes nothing', () {
      final state = after(3, also: (log) => log.deload(10));

      expect(state.isDeload, isTrue);
      expect(state.totalPasses, 10);
    });

    test('deload now with no deload rule adds a pass', () {
      final state = after(0, every: null, also: (log) => log.deload(10));

      expect(state.isDeload, isTrue);
      expect(state.totalPasses, 11);
    });
  });

  group('resolveTarget', () {
    const base = Target(sets: 4, reps: 6, rpe: 8);

    PhaseExerciseTarget override({int? rpe, int? sets, int? reps}) =>
        PhaseExerciseTarget(
          id: 1,
          phaseId: 10,
          categoryId: 1,
          targetRpe: rpe,
          targetSets: sets,
          targetReps: reps,
        );

    test("without a phase override the workout's own target stands", () {
      final t = resolveTarget(base, null, deload: false);

      expect((t.sets, t.reps, t.rpe, t.isDeload), (4, 6, 8, false));
    });

    test('a phase override replaces only the fields it sets', () {
      final t = resolveTarget(base, override(rpe: 7, reps: 10), deload: false);

      expect((t.sets, t.reps, t.rpe), (4, 10, 7));
    });

    test('a deload drops the RPE to 5 and keeps the volume', () {
      final t = resolveTarget(base, override(rpe: 9, sets: 5), deload: true);

      expect((t.sets, t.reps, t.rpe, t.isDeload), (5, 6, 5, true));
    });

    test('a deload sets an RPE even where none was planned', () {
      final t = resolveTarget(const Target(sets: 3), null, deload: true);

      expect(t.rpe, 5);
    });
  });
}
