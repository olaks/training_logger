import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/periodization.dart';

/// [resolvePlan] with each phase's rotation as a one-day cycle: how plans
/// periodized before microcycles migrated, which must behave as rotations
/// always did.
PlanState resolve(List<PlanPhase> phases, Map<int, List<int>> rotations,
        List<PlanEvent> events) =>
    resolvePlan(phases, oneDay(rotations), events,
        cycleDays: 1, today: DateTime(2026, 1, 1));

PlanProjection project(List<PlanPhase> phases,
        Map<int, List<int>> rotations, List<PlanEvent> events,
        DateTime today) =>
    projectPlan(phases, oneDay(rotations), events,
        cycleDays: 1, today: today);

Map<int, Cycle> oneDay(Map<int, List<int>> rotations) => {
      for (final MapEntry(:key, :value) in rotations.entries) key: {1: value},
    };

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
        closesDay: closes,
        day: workoutId == null ? null : 1,
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
      final state = resolve(
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
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 1);
      expect(state.remaining, [b]);
    });

    test('doing every session of the rotation starts the next pass', () {
      final log = Log()..done(10, [b, c, a]);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
      expect(state.remaining, [a, b, c]);
    });

    test('a skipped session counts towards finishing the pass', () {
      final log = Log()
        ..done(10, [a, c])
        ..skip(10, b);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
    });

    test('repeating a session already done this pass does not finish it', () {
      final log = Log()..done(10, [a, a, b, b]);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 1);
      expect(state.remaining, [c]);
    });

    test('a session outside the rotation is ignored', () {
      final log = Log()..done(10, [d]);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.remaining, [a, b, c]);
    });

    test('a finished phase waits on its last pass for the athlete to move on',
        () {
      final log = Log()..passes(10, [a, b], 3);
      final state = resolve(
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
      final state = resolve(
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
      final state = resolve([phase(10), phase(20, order: 1)],
          {10: [a, b], 20: [c]}, log.events);

      expect(state.phase?.id, 20);
    });

    test('phases run in their sort order, not list order', () {
      final state = resolve([phase(20, order: 1), phase(10)],
          {10: [a], 20: [b]}, const []);

      expect(state.phase?.id, 10);
    });

    test('moving on from the last phase ends the plan', () {
      final log = Log()
        ..passes(10, [a], 2)
        ..advance(10);
      final state =
          resolve([phase(10, passes: 2)], {10: [a]}, log.events);

      expect(state.planComplete, isTrue);
      expect(state.phase, isNull);
    });

    test('a plan with no phases has nothing to do', () {
      final state = resolve(const [], const {}, const []);

      expect(state.planComplete, isTrue);
      expect(state.phase, isNull);
      expect(state.remaining, isEmpty);
    });

    test('sessions done while a finished phase waits count once it is '
        'lengthened', () {
      final log = Log()..passes(10, [a, b], 3);

      expect(
          resolve([phase(10, passes: 2)], {10: [a, b]}, log.events)
              .phaseComplete,
          isTrue);

      final extended =
          resolve([phase(10, passes: 5)], {10: [a, b]}, log.events);
      expect(extended.pass, 4);
      expect(extended.phaseComplete, isFalse);
    });
  });

  group('editing a phase mid-plan', () {
    test('shortening a phase below the weeks done finishes it', () {
      final log = Log()..passes(10, [a, b], 5);
      final state =
          resolve([phase(10, passes: 4)], {10: [a, b]}, log.events);

      expect(state.phaseComplete, isTrue);
      expect(state.pass, 4);
    });

    test('lengthening a phase gives it more weeks to go', () {
      final log = Log()..passes(10, [a, b], 3);
      final state =
          resolve([phase(10, passes: 12)], {10: [a, b]}, log.events);

      expect((state.pass, state.totalPasses), (4, 12));
    });

    test('changing the deload rule moves the deloads still to come', () {
      final log = Log()..passes(10, [a, b], 2);

      final every4 = resolve(
          [phase(10, deloadEvery: 4)], {10: [a, b]}, log.events);
      expect(every4.passesUntilDeload, 1);

      final every5 = resolve(
          [phase(10, deloadEvery: 5)], {10: [a, b]}, log.events);
      expect(every5.passesUntilDeload, 2);
    });

    test('a later phase can be edited without touching the current one', () {
      final log = Log()..passes(10, [a, b], 2);
      final before = resolve([phase(10), phase(20, order: 1)],
          {10: [a, b], 20: [c]}, log.events);
      final after = resolve(
          [phase(10), phase(20, passes: 3, deloadEvery: 2, order: 1)],
          {10: [a, b], 20: [c, d]}, log.events);

      expect((after.phase?.id, after.pass), (before.phase?.id, before.pass));
      expect(after.remaining, before.remaining);
    });
  });

  group('session counts', () {
    test('a phase counts the sessions done and skipped in it', () {
      final log = Log()
        ..passes(10, [a, b], 2)
        ..done(10, [a])
        ..skip(10, b)
        ..done(10, [a]);
      final state = resolve([phase(10)], {10: [a, b]}, log.events);

      expect((state.sessionsDone, state.sessionsSkipped), (6, 1));
    });

    test('a session repeated in its week still counts as done', () {
      final log = Log()..done(10, [a, a]);
      final state = resolve([phase(10)], {10: [a, b]}, log.events);

      expect(state.sessionsDone, 2);
      expect(state.remaining, [b]);
    });

    test('only the current phase is counted', () {
      final log = Log()
        ..passes(10, [a], 3)
        ..advance(10)
        ..done(20, [b]);
      final state = resolve(
          [phase(10), phase(20, order: 1)], {10: [a], 20: [b, c]}, log.events);

      expect(state.sessionsDone, 1);
    });
  });

  group('editing a rotation mid-plan', () {
    test('adding a session keeps the weeks already done', () {
      final log = Log()
        ..passes(10, [a, b], 3)
        ..done(10, [a]);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 4);
      expect(state.remaining, [b, c],
          reason: 'the new session is due from the current week');
    });

    test('removing a session keeps the weeks already done', () {
      final log = Log()
        ..passes(10, [a, b, c], 2)
        ..done(10, [a]);
      final state = resolve([phase(10)], {10: [a, b]}, log.events);

      expect(state.pass, 3);
      expect(state.remaining, [b]);
    });

    test('removing the only session left to do finishes the week', () {
      final log = Log()
        ..passes(10, [a, b], 2)
        ..done(10, [a]);
      final state = resolve([phase(10)], {10: [a]}, log.events);

      expect(state.pass, 4);
      expect(state.remaining, [a]);
    });

    test('adding a session to a finished week leaves it finished', () {
      final log = Log()..passes(10, [a, b], 1);
      final state = resolve([phase(10)], {10: [a, b, c]}, log.events);

      expect(state.pass, 2);
      expect(state.remaining, [a, b, c]);
    });

    test('undoing the session that finished a week reopens it, new session '
        'and all', () {
      final log = Log()..passes(10, [a, b], 1);
      final events = log.events.sublist(0, log.events.length - 1);
      final state = resolve([phase(10)], {10: [a, b, c]}, events);

      expect(state.pass, 1);
      expect(state.remaining, [b, c]);
    });

    test('emptying the rotation keeps the weeks already done', () {
      final log = Log()..passes(10, [a, b], 2);
      final state = resolve([phase(10)], {10: []}, log.events);

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
      final state = resolve([phase(10)], {10: [b]}, events);

      expect(state.pass, 3, reason: 'two weeks done, the third under way');
      expect(state.remaining, [b]);
    });

    test('undoing the session that started a week goes back to the one '
        'before', () {
      final log = Log()..passes(10, [a, b], 2);
      final events = log.events.sublist(0, log.events.length - 1);
      final state = resolve([phase(10)], {10: [a, b]}, events);

      expect(state.pass, 2);
      expect(state.remaining, [b]);
    });
  });

  group('deloads', () {
    PlanState after(int passes, {int length = 10, int? every = 4,
        void Function(Log)? also}) {
      final log = Log()..passes(10, [a, b], passes);
      also?.call(log);
      return resolve([phase(10, passes: length, deloadEvery: every)],
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

  group('microcycles', () {
    /// An 8-day cycle: two workouts on day 1, one on day 2, rest on day 3,
    /// one on day 4, rest for the rest of the cycle.
    const cycle = {
      1: [a, b],
      2: [c],
      4: [d],
    };
    final events = <PlanEvent>[];
    setUp(events.clear);

    /// Logs [workout] (null: "skip rest day") on [date], stamped with the day
    /// it was recorded for, as the database stamps it.
    void log(int? workout, String date,
        {required int pass, required int day, bool closes = false,
        PlanEventKind kind = PlanEventKind.done}) {
      events.add(PlanEvent(
        id: events.length + 1,
        planId: 1,
        phaseId: 10,
        workoutId: workout,
        pass: pass,
        day: day,
        closesDay: closes,
        dateStr: date,
        timestamp: events.length + 1,
        kind: kind,
      ));
    }

    PlanState on(String today) => resolvePlan(
          [phase(10, passes: 3)],
          {10: cycle},
          events,
          cycleDays: 8,
          today: DateTime.parse(today),
        );

    test('a day is done once every workout on it is, in any order', () {
      log(b, '2026-10-01', pass: 1, day: 1);
      expect(on('2026-10-01').remaining, [a]);

      log(a, '2026-10-01', pass: 1, day: 1, closes: true);
      final s = on('2026-10-01');
      expect(s.day, 2);
      expect(s.remaining, [c]);
      expect(s.upFrom, DateTime.utc(2026, 10, 2),
          reason: 'the next day is up tomorrow');
    });

    test('a missed day waits', () {
      log(a, '2026-10-01', pass: 1, day: 1);
      log(b, '2026-10-01', pass: 1, day: 1, closes: true);

      expect(on('2026-10-20').day, 2,
          reason: 'only training moves a training day');
    });

    test('a rest day takes its calendar day and then passes', () {
      log(a, '2026-10-01', pass: 1, day: 1);
      log(b, '2026-10-01', pass: 1, day: 1, closes: true);
      log(c, '2026-10-02', pass: 1, day: 2, closes: true);

      final rest = on('2026-10-03');
      expect((rest.day, rest.isRestDay), (3, true));
      expect(rest.due?.day, 4,
          reason: 'the next training day can be trained instead');
      expect(rest.due?.workouts, [d]);

      final after = on('2026-10-04');
      expect((after.day, after.isRestDay), (4, false));
      expect(after.remaining, [d]);
    });

    test('skipping a rest day puts the next day up at once', () {
      log(a, '2026-10-01', pass: 1, day: 1);
      log(b, '2026-10-01', pass: 1, day: 1, closes: true);
      log(c, '2026-10-02', pass: 1, day: 2, closes: true);
      log(null, '2026-10-03',
          pass: 1, day: 3, closes: true, kind: PlanEventKind.skip);

      final s = on('2026-10-03');
      expect(s.day, 4);
      expect(s.remaining, [d]);
      expect(s.sessionsSkipped, 0, reason: 'a rest day is not a session');
    });

    test('training the next day during a rest day skips the rest', () {
      log(a, '2026-10-01', pass: 1, day: 1);
      log(b, '2026-10-01', pass: 1, day: 1, closes: true);
      log(c, '2026-10-02', pass: 1, day: 2, closes: true);
      log(d, '2026-10-03', pass: 1, day: 4, closes: true);

      final s = on('2026-10-03');
      expect(s.day, 5);
    });

    test('the rest days at the end of a cycle lead into the next one', () {
      log(a, '2026-10-01', pass: 1, day: 1);
      log(b, '2026-10-01', pass: 1, day: 1, closes: true);
      log(c, '2026-10-02', pass: 1, day: 2, closes: true);
      log(d, '2026-10-04', pass: 1, day: 4, closes: true);

      final resting = on('2026-10-06');
      expect((resting.pass, resting.day, resting.isRestDay), (1, 6, true));
      expect((resting.due?.pass, resting.due?.day), (2, 1));

      // Days 5 to 8 rest on the 5th to the 8th; the next cycle is up on the
      // 9th.
      final next = on('2026-10-09');
      expect((next.pass, next.day), (2, 1));
      expect(next.remaining, [a, b]);
    });

    test('a plan that opens on a rest day waits to be told to start', () {
      final s = resolvePlan(
        [phase(10, passes: 3)],
        {
          10: {
            2: [a],
          },
        },
        const [],
        cycleDays: 8,
        today: DateTime(2026, 10, 9),
      );

      expect((s.day, s.isRestDay), (1, true),
          reason: 'with nothing before it there is no date to count from');
      expect(s.due?.day, 2);
    });

    test('a cycle with no workouts on the stamped day still moves on', () {
      // The day was emptied after it was trained.
      log(a, '2026-10-01', pass: 1, day: 3, closes: true);

      expect(on('2026-10-01').day, 4);
    });
  });

  group('projectPlan', () {
    final today = DateTime(2026, 10, 8);
    DateTime day(String s) => DateTime.utc(
        int.parse(s.substring(0, 4)),
        int.parse(s.substring(5, 7)),
        int.parse(s.substring(8)));

    /// Sessions of [rotation] on consecutive [dates], a pass at a time, as
    /// the database stamps them.
    List<PlanEvent> sessions(int phaseId, List<int> rotation,
        List<String> dates, {int firstId = 1}) {
      return [
        for (var i = 0; i < dates.length; i++)
          PlanEvent(
            id: firstId + i,
            planId: 1,
            phaseId: phaseId,
            workoutId: rotation[i % rotation.length],
            pass: i ~/ rotation.length + 1,
            day: 1,
            closesDay: i % rotation.length == rotation.length - 1,
            dateStr: dates[i],
            timestamp: firstId + i,
            kind: PlanEventKind.done,
          ),
      ];
    }

    PlanEvent event(int id, int phaseId, PlanEventKind kind, String date) =>
        PlanEvent(
          id: id,
          planId: 1,
          phaseId: phaseId,
          closesDay: false,
          dateStr: date,
          timestamp: id,
          kind: kind,
        );

    test('without a recent pace every pass is taken as a week', () {
      final p = project(
        [phase(10, passes: 4, deloadEvery: 2), phase(20, passes: 2, order: 1)],
        {10: [a, b, c], 20: [d]},
        const [],
        today,
      );

      expect(p.sessionsPerWeek, isNull);
      final [first, second] = p.phases;
      expect((first.start, first.end), (day('2026-10-08'), day('2026-11-05')));
      expect(first.deloads, [day('2026-10-15'), day('2026-10-29')]);
      expect(first.started, isFalse);
      expect((second.start, second.end),
          (day('2026-11-05'), day('2026-11-19')));
      expect(p.end, day('2026-11-19'));
    });

    test('the pace of the recent sessions sets how long a pass takes', () {
      // Three sessions a week for two weeks: two passes of three done.
      final log = sessions(10, [a, b, c], [
        '2026-09-25', '2026-09-28', '2026-09-30',
        '2026-10-02', '2026-10-05', '2026-10-07',
      ]);
      final p = project(
          [phase(10, passes: 4)], {10: [a, b, c]}, log, today);

      expect(p.sessionsPerWeek, closeTo(3, 1e-9));
      final [only] = p.phases;
      expect((only.start, only.started), (day('2026-09-25'), true));
      // Passes 3 and 4 still to go, a week each.
      expect(only.end, day('2026-10-22'));
    });

    test('a pass under way counts only the sessions still due', () {
      final log = sessions(10, [a, b, c], [
        '2026-09-25', '2026-09-28', '2026-09-30',
        '2026-10-02', '2026-10-05', '2026-10-07',
        '2026-10-08', '2026-10-08',
      ]);
      final p = project(
          [phase(10, passes: 3)], {10: [a, b, c]}, log, today);

      // Eight sessions over fourteen days make a pass of three 5¼ days, and
      // a third of one is left: 1¾ days, so the 10th.
      expect(p.phases.single.end, day('2026-10-10'));
    });

    test('a cycle takes at least its days, however fast it is trained', () {
      // About two sessions a week, and an 8-day cycle with one workout: that
      // pace would finish one every 3½ days, but a day can't be trained
      // before it is up.
      final log = sessions(10, [a], [
        '2026-09-14', '2026-09-17', '2026-09-21', '2026-09-24',
        '2026-09-28', '2026-10-01', '2026-10-05', '2026-10-08',
      ]);
      final p = projectPlan(
        [phase(10, passes: 10), phase(20, passes: 3, order: 1)],
        {
          10: {1: [a]},
          20: {1: [b]},
        },
        log,
        cycleDays: 8,
        today: today,
      );

      final [_, next] = p.phases;
      expect(next.end.difference(next.start).inDays, 24);
    });

    test('a longer rotation runs at the pace it is trained', () {
      // Six sessions a week through a rotation of three: two passes a week.
      final log = sessions(10, [a, b, c], [
        '2026-09-27', '2026-09-28', '2026-09-29', '2026-09-30',
        '2026-10-01', '2026-10-02', '2026-10-04', '2026-10-05',
        '2026-10-06', '2026-10-07', '2026-10-08', '2026-10-08',
      ]);
      final p = project(
        [phase(10, passes: 6), phase(20, passes: 4, order: 1)],
        {10: [a, b, c], 20: [a, b, c]},
        log,
        today,
      );

      // Twelve sessions in twelve days: a pass of three takes three days.
      final [_, next] = p.phases;
      expect(next.end.difference(next.start).inDays, 12);
    });

    test('sessions older than the window give no pace', () {
      final log = sessions(10, [a, b, c], [
        '2026-08-01', '2026-08-03', '2026-08-05', '2026-09-10',
      ]);
      final p = project(
          [phase(10, passes: 4)], {10: [a, b, c]}, log, today);

      expect(p.sessionsPerWeek, isNull);
    });

    test('a phase moved on from keeps the days it actually ran', () {
      final log = [
        ...sessions(10, [a], ['2026-08-03', '2026-08-10']),
        event(3, 10, PlanEventKind.advance, '2026-08-20'),
      ];
      final p = project(
        [phase(10, passes: 2), phase(20, passes: 2, order: 1)],
        {10: [a], 20: [b]},
        log,
        today,
      );

      final [done, now] = p.phases;
      expect((done.start, done.end, done.finished),
          (day('2026-08-03'), day('2026-08-20'), true));
      // The next phase began the day this one was moved on from, sessions
      // or not, so there is no gap between them.
      expect((now.start, now.started, now.finished),
          (day('2026-08-20'), true, false));
    });

    test('a deload now shows on the timeline and lengthens the phase', () {
      final p = project(
        [phase(10, passes: 2)],
        {10: [a]},
        [event(1, 10, PlanEventKind.deload, '2026-10-08')],
        today,
      );

      final [only] = p.phases;
      expect(only.deloads, [day('2026-10-08')]);
      expect(only.end, day('2026-10-29'));
    });

    test('a finished phase waiting to move on ends today', () {
      final log = sessions(10, [a], ['2026-10-01', '2026-10-06']);
      final p = project(
        [phase(10, passes: 2, deloadEvery: 2), phase(20, passes: 1, order: 1)],
        {10: [a], 20: [b]},
        log,
        today,
      );

      final [waiting, next] = p.phases;
      expect(waiting.end, day('2026-10-08'));
      expect(waiting.deloads, isEmpty);
      expect(next.start, day('2026-10-08'));
    });
  });

  group('resolveTarget', () {
    const base = Target(sets: 4, reps: 6, rpe: 8);

    Target override({int? rpe, int? sets, int? reps}) =>
        Target(rpe: rpe, sets: sets, reps: reps);

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
