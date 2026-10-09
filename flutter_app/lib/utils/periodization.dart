import '../database/database.dart';
import 'format_utils.dart';

/// Where a periodized plan stands, replayed from its event log.
///
/// A plan runs its phases in order. A phase lasts a number of *passes* — one
/// trip through its microcycle, a fixed number of days each holding some
/// workouts (or none, for rest) — so missed days never move the plan; only
/// logged sessions do, and the calendar only moves rest days along. Nothing
/// about the position is stored: everything here is a pure function of the
/// phases, their cycles, the events and today's date, so it can be tested
/// without a database, and undo or editing a phase mid-plan just means
/// replaying again.

/// The target RPE for every exercise during a deload pass.
const kDeloadRpe = 5;

/// How many passes ahead a scheduled deload can be and still be the one a
/// "deload now" takes early. Any further off and the manual deload is extra.
const kDeloadReplaceWindow = 2;

/// A phase's microcycle: 1-based day → the workout ids on it, in order. A day
/// missing from the map or holding nothing is a rest day.
typedef Cycle = Map<int, List<int>>;

/// Each phase's cycle from its [sessions] rows: every phase of [phases] gets
/// one, empty if it has no sessions yet.
Map<int, Cycle> cyclesOf(
    List<PlanPhase> phases, List<PhaseSession> sessions) {
  final rows = [...sessions]..sort((x, y) => x.day != y.day
      ? x.day.compareTo(y.day)
      : x.sortOrder.compareTo(y.sortOrder));
  final cycles = {for (final p in phases) p.id: <int, List<int>>{}};
  for (final s in rows) {
    cycles[s.phaseId]?.putIfAbsent(s.day, () => []).add(s.workoutId);
  }
  return cycles;
}

/// Every workout in [cycle], each once, in day order.
List<int> cycleWorkouts(Cycle cycle) => {
      for (final d in cycle.keys.toList()..sort()) ...cycle[d]!,
    }.toList();

/// What the UI calls a pass of a plan whose cycles have [cycleDays] days: a
/// week when it is one — and for a one-day cycle, which holds a whole
/// rotation of the kind the UI always called a week.
String cycleWord(int cycleDays) =>
    cycleDays == 7 || cycleDays == 1 ? 'week' : 'cycle';

/// What is left to train of the current day, or that it is up tomorrow when
/// the day before it finished today. A one-day cycle's day lasts as long as
/// its workouts take, so its count is for the week, and it is never
/// "tomorrow".
String workoutsLeftLine(PlanState s, DateTime now) {
  final left = s.remaining.length;
  final workouts = left == 1 ? '1 workout' : '$left workouts';
  if (s.cycleDays == 1) return '$workouts left this week';
  final upFrom = s.upFrom;
  if (upFrom != null && upFrom.isAfter(_day(now))) {
    return 'Day ${s.day} is up tomorrow: $workouts';
  }
  return '$workouts left today';
}

/// The day whose workouts are due, and which of them still are.
typedef DueDay = ({int pass, int day, List<int> workouts});

/// The position of a plan, as [resolvePlan] works it out.
class PlanState {
  /// The phase being worked through, or null once the plan is over.
  final PlanPhase? phase;

  /// 1-based pass (microcycle) within [phase].
  final int pass;

  /// 1-based day of [pass].
  final int day;

  /// Days in a microcycle.
  final int cycleDays;

  /// Passes of [phase] finished so far. Unlike [pass], not capped at
  /// [totalPasses]: a finished phase keeps counting while it waits.
  final int passesDone;

  /// Passes in [phase], including any deloads inserted by hand.
  final int totalPasses;

  /// Sessions done and skipped in [phase] so far, every one logged — a
  /// session repeated within its day counts again here, though it does
  /// nothing for the day.
  final int sessionsDone;
  final int sessionsSkipped;

  /// Workouts of the current day not yet done or skipped, in order. Empty on
  /// a rest day.
  final List<int> remaining;

  /// The current day has no workouts.
  final bool isRestDay;

  /// The first calendar day the current day is up: the day after the one
  /// before it finished. Null when no day of the phase has finished yet.
  final DateTime? upFrom;

  /// What can be trained now: the current day's [remaining] workouts, or on
  /// a rest day the whole of the next day with workouts — training it skips
  /// the rest. Null when nothing in the phase is left.
  final DueDay? due;

  /// The current pass is a deload: every target drops to [kDeloadRpe].
  final bool isDeload;

  /// Passes from the current one to the next deload in [phase]: 0 while in
  /// one, null when none is left.
  final int? passesUntilDeload;

  /// Every deload pass of [phase], 1-based and in order: the phase's rule as
  /// reshaped by each "deload now".
  final List<int> deloads;

  /// Every pass of [phase] is done; waiting for the athlete to move on.
  final bool phaseComplete;

  final bool planComplete;

  const PlanState({
    required this.phase,
    required this.pass,
    required this.day,
    required this.cycleDays,
    required this.passesDone,
    required this.totalPasses,
    required this.sessionsDone,
    required this.sessionsSkipped,
    required this.remaining,
    required this.isRestDay,
    required this.upFrom,
    required this.due,
    required this.isDeload,
    required this.passesUntilDeload,
    required this.deloads,
    required this.phaseComplete,
    required this.planComplete,
  });
}

/// Replays [events] against [phases] (in any order; sorted by `sortOrder`)
/// and their [cycles] (phase id → its microcycle of [cycleDays] days), as of
/// [today], which moves rest days along.
PlanState resolvePlan(
  List<PlanPhase> phases,
  Map<int, Cycle> cycles,
  List<PlanEvent> events, {
  required int cycleDays,
  required DateTime today,
}) {
  today = _day(today);
  final days = cycleDays < 1 ? 1 : cycleDays;
  final ordered = [...phases]
    ..sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
  final log = [...events]
    ..sort((x, y) => x.timestamp != y.timestamp
        ? x.timestamp.compareTo(y.timestamp)
        : x.id.compareTo(y.id));

  // A phase is behind the athlete once they have moved on from it, whether or
  // not every pass was done — moving on early is allowed.
  final advanced = {
    for (final e in log)
      if (e.kind == PlanEventKind.advance) e.phaseId,
  };
  final current = ordered.where((p) => !advanced.contains(p.id)).firstOrNull;
  if (current == null) {
    return PlanState(
      phase: null,
      pass: 0,
      day: 0,
      cycleDays: days,
      passesDone: 0,
      totalPasses: 0,
      sessionsDone: 0,
      sessionsSkipped: 0,
      remaining: const [],
      isRestDay: false,
      upFrom: null,
      due: null,
      isDeload: false,
      passesUntilDeload: null,
      deloads: const [],
      phaseComplete: false,
      planComplete: true,
    );
  }

  final cycle = cycles[current.id] ?? const <int, List<int>>{};
  List<int> on(int day) => cycle[day] ?? const [];
  var total = current.lengthPasses;
  // 1-based passes that are deloads: the phase's rule first, then reshaped by
  // each "deload now" as it comes.
  final every = current.deloadEvery;
  var deloads = <int>{
    if (every != null && every > 0)
      for (var p = every; p <= total; p += every) p,
  };
  var passesDone = 0;
  var day = 1;
  var sessionsDone = 0;
  var sessionsSkipped = 0;
  final covered = <int>{};
  // The phase's first day is up from the day the phase before it was moved
  // on from; with no phase before, there is no date to count a rest from.
  DateTime? upFrom = log
      .where((e) => e.kind == PlanEventKind.advance)
      .map((e) => _day(dateFromStr(e.dateStr)))
      .fold<DateTime?>(null, (m, d) => m == null || d.isAfter(m) ? d : m);

  void nextDay(DateTime up) {
    covered.clear();
    upFrom = up;
    if (++day > days) {
      day = 1;
      passesDone++;
    }
  }

  // A rest day takes the one calendar day it is up on, and is over once that
  // date is behind [date].
  void restBefore(DateTime date) {
    while (passesDone < total &&
        on(day).isEmpty &&
        upFrom != null &&
        upFrom!.isBefore(date)) {
      nextDay(upFrom!.add(const Duration(days: 1)));
    }
  }

  for (final e in log.where((e) => e.phaseId == current.id)) {
    final date = _day(dateFromStr(e.dateStr));
    switch (e.kind) {
      case PlanEventKind.done:
      case PlanEventKind.skip:
        // A skip with no workout is "skip rest day", not a session — or a
        // skipped session whose workout has since been deleted, which goes
        // uncounted with it.
        if (e.kind == PlanEventKind.done) {
          sessionsDone++;
        } else if (e.workoutId != null) {
          sessionsSkipped++;
        }
        restBefore(date);
        // Each session carries the day it was recorded for, and whether it
        // finished that day. Both stand whatever the cycle has become since:
        // a later stamp means every day before it was finished (a rest day
        // trained through, or days since removed), an earlier one belongs to
        // a day already behind.
        final stampPass = e.pass ?? passesDone + 1;
        final stampDay = e.day ?? day;
        final behind = stampPass != passesDone + 1
            ? stampPass < passesDone + 1
            : stampDay < day;
        if (behind) continue;
        if (stampPass != passesDone + 1 || stampDay != day) {
          passesDone = stampPass - 1;
          day = stampDay;
          covered.clear();
        }
        // A workout not on the day (or whose workout is gone) does nothing
        // for it unless it was the one that finished it.
        if (on(day).contains(e.workoutId)) covered.add(e.workoutId!);
        if (e.closesDay || on(day).every(covered.contains)) {
          // A rest day ended early ("skip rest day") puts the next day up at
          // once; a trained day's next is up the day after.
          nextDay(on(day).isEmpty ? date : date.add(const Duration(days: 1)));
        }
      case PlanEventKind.deload:
        // The deload goes on the first pass not yet started.
        final started = day > 1 || covered.isNotEmpty;
        final target = passesDone + (started ? 2 : 1);
        if (deloads.contains(target)) continue;
        final next = deloads.where((p) => p > target).fold<int?>(
            null, (m, p) => m == null || p < m ? p : m);
        if (next != null && next - target <= kDeloadReplaceWindow) {
          // Taking the scheduled deload early rather than doubling up.
          deloads = {...deloads..remove(next), target};
        } else {
          // An extra pass, with the loading pattern after it kept intact.
          deloads = {
            for (final p in deloads) p > target ? p + 1 : p,
            target,
          };
          total++;
        }
      case PlanEventKind.advance:
        break;
    }
  }
  restBefore(today);

  // Sessions done after the last pass are kept rather than capped, so that
  // lengthening a finished phase credits them.
  final complete = passesDone >= total;
  final pass = complete ? total : passesDone + 1;
  final upcoming = deloads.where((p) => p >= pass).toList()..sort();
  final remaining = complete
      ? const <int>[]
      : [
          for (final w in on(day))
            if (!covered.contains(w)) w,
        ];
  final isRest = !complete && on(day).isEmpty;

  DueDay? due;
  if (!complete && !isRest) {
    due = (pass: pass, day: day, workouts: remaining);
  } else if (isRest) {
    // The next day with workouts within the phase. One lap of the cycle
    // finds it if there is one at all.
    var p = pass, d = day;
    for (var i = 0; i < days; i++) {
      if (++d > days) {
        d = 1;
        p++;
      }
      if (p > total) break;
      if (on(d).isNotEmpty) {
        due = (pass: p, day: d, workouts: on(d));
        break;
      }
    }
  }

  return PlanState(
    phase: current,
    pass: pass,
    day: complete ? days : day,
    cycleDays: days,
    passesDone: passesDone,
    totalPasses: total,
    sessionsDone: sessionsDone,
    sessionsSkipped: sessionsSkipped,
    remaining: remaining,
    isRestDay: isRest,
    upFrom: complete ? null : upFrom,
    due: due,
    isDeload: !complete && deloads.contains(pass),
    passesUntilDeload:
        complete || upcoming.isEmpty ? null : upcoming.first - pass,
    deloads: deloads.toList()..sort(),
    phaseComplete: complete,
    planComplete: false,
  );
}

// ── Projected timeline ────────────────────────────────────────────────────────

/// How many days back a plan's pace is measured over.
const kPaceWindowDays = 28;

/// The fewest sessions in the window that a pace is trusted from. With fewer,
/// a pass is taken to last its cycle's days (a one-day cycle, a week).
const kPaceMinSessions = 3;

/// One phase laid out in time. Dates are days, as UTC midnights.
class PhaseProjection {
  final PlanPhase phase;
  final DateTime start;

  /// The day the phase is expected to finish, which is the day the next one
  /// starts. For a phase moved on from, the day that happened.
  final DateTime end;

  /// [start] comes from the log, not the pace: the day the phase before was
  /// moved on from, or for the first phase its first session.
  final bool started;

  /// The phase has been moved on from, so [end] is not an estimate either.
  final bool finished;

  /// The expected first day of each deload pass still ahead in the phase.
  final List<DateTime> deloads;

  const PhaseProjection({
    required this.phase,
    required this.start,
    required this.end,
    required this.started,
    required this.finished,
    required this.deloads,
  });
}

/// A plan laid out in time: the phases behind, from the log, and the rest
/// estimated at the pace of the last [kPaceWindowDays] days.
class PlanProjection {
  /// In plan order. Empty for a plan without phases.
  final List<PhaseProjection> phases;

  /// The pace assumed, or null when there were too few recent sessions to
  /// measure one and every cycle was taken at its length.
  final double? sessionsPerWeek;

  /// Where the plan stands, as [resolvePlan] has it.
  final PlanState state;

  const PlanProjection({
    required this.phases,
    required this.sessionsPerWeek,
    required this.state,
  });

  DateTime? get end => phases.lastOrNull?.end;
}

/// Lays out [phases] in time from [today], replaying [events] as
/// [resolvePlan] does. A cycle takes at least its [cycleDays] — a day can't
/// be trained before it is up — and longer when the sessions logged per day
/// lately fall short of the cycle's.
PlanProjection projectPlan(
  List<PlanPhase> phases,
  Map<int, Cycle> cycles,
  List<PlanEvent> events, {
  required int cycleDays,
  required DateTime today,
}) {
  today = _day(today);
  final state = resolvePlan(phases, cycles, events,
      cycleDays: cycleDays, today: today);
  final days = state.cycleDays;
  final ordered = [...phases]
    ..sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
  final perDay = _sessionsPerDay(events, today);

  int sessionsIn(Cycle c) => c.values.fold(0, (n, w) => n + w.length);
  double passDays(int sessions) {
    // A one-day cycle is a whole old rotation, which ran about a week.
    final floor = days == 1 && perDay == null ? 7.0 : days.toDouble();
    if (perDay == null || sessions == 0) return floor;
    final atPace = sessions / perDay;
    return atPace < floor ? floor : atPace;
  }

  DateTime after(double days) => today.add(Duration(days: days.round()));

  // Days from today to where the phase being laid out begins.
  var cursor = 0.0;
  // When the last phase moved on from ended, which is when the next began.
  DateTime? movedOn;
  final out = <PhaseProjection>[];
  for (final p in ordered) {
    final own = [
      for (final e in events)
        if (e.phaseId == p.id) _day(dateFromStr(e.dateStr)),
    ]..sort();
    final advance = [
      for (final e in events)
        if (e.phaseId == p.id && e.kind == PlanEventKind.advance)
          _day(dateFromStr(e.dateStr)),
    ]..sort();
    final cycle = cycles[p.id] ?? const <int, List<int>>{};
    final sessions = sessionsIn(cycle);
    final pass = passDays(sessions);

    final began = movedOn ?? own.firstOrNull;
    if (advance.isNotEmpty) {
      movedOn = advance.last;
      out.add(PhaseProjection(
        phase: p,
        start: began!,
        end: advance.last,
        started: true,
        finished: true,
        deloads: const [],
      ));
    } else if (p.id == state.phase?.id) {
      // What is left of the cycle under way, as a fraction of a cycle —
      // by sessions when it has any, else by days — then the cycles after.
      final double partial;
      if (state.phaseComplete) {
        partial = 0;
      } else if (sessions == 0) {
        partial = (days - state.day + 1) / days;
      } else {
        var left = state.remaining.length;
        for (var d = state.day + 1; d <= days; d++) {
          left += cycle[d]?.length ?? 0;
        }
        partial = left / sessions;
      }
      final left = state.phaseComplete
          ? 0.0
          : partial + state.totalPasses - state.pass;
      out.add(PhaseProjection(
        phase: p,
        start: began ?? today,
        end: after(left * pass),
        started: began != null,
        finished: false,
        deloads: [
          if (!state.phaseComplete)
            for (final d in state.deloads)
              if (d == state.pass)
                today
              else if (d > state.pass)
                after((partial + d - state.pass - 1) * pass),
        ],
      ));
      cursor = left * pass;
    } else {
      final every = p.deloadEvery;
      out.add(PhaseProjection(
        phase: p,
        start: after(cursor),
        end: after(cursor + p.lengthPasses * pass),
        started: false,
        finished: false,
        deloads: [
          if (every != null && every > 0)
            for (var d = every; d <= p.lengthPasses; d += every)
              after(cursor + (d - 1) * pass),
        ],
      ));
      cursor += p.lengthPasses * pass;
    }
  }
  return PlanProjection(
    phases: out,
    sessionsPerWeek: perDay == null ? null : perDay * 7,
    state: state,
  );
}

/// Workouts done or skipped per day over the last [kPaceWindowDays] days up
/// to [today], or since the first one if that is more recent — though never
/// over fewer than seven days, so that one busy weekend isn't the pace.
double? _sessionsPerDay(List<PlanEvent> events, DateTime today) {
  final days = [
    for (final e in events)
      // A skip with no workout is a rest day skipped, not a session.
      if (e.kind == PlanEventKind.done ||
          (e.kind == PlanEventKind.skip && e.workoutId != null))
        _day(dateFromStr(e.dateStr)),
  ];
  if (days.isEmpty) return null;
  final windowStart = today.subtract(const Duration(days: kPaceWindowDays - 1));
  final recent =
      days.where((d) => !d.isBefore(windowStart) && !d.isAfter(today)).length;
  if (recent < kPaceMinSessions) return null;
  final first = days.reduce((x, y) => x.isBefore(y) ? x : y);
  final from = first.isAfter(windowStart) ? first : windowStart;
  final span = today.difference(from).inDays + 1;
  return recent / (span < 7 ? 7 : span);
}

/// [d]'s calendar day as a UTC midnight, so that adding days never trips over
/// a daylight-saving change.
DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// What an exercise is planned to be: any field may be unset.
class Target {
  final int? sets;
  final int? reps;
  final int? rpe;
  final bool isDeload;

  const Target({this.sets, this.reps, this.rpe, this.isDeload = false});

  /// No sets, reps or RPE set.
  bool get isEmpty => sets == null && reps == null && rpe == null;
}

extension WorkoutExerciseTarget on WorkoutExercise {
  Target get target =>
      Target(sets: targetSets, reps: targetReps, rpe: targetRpe);
}

extension PhaseOverrideTarget on PhaseExerciseTarget {
  Target get target =>
      Target(sets: targetSets, reps: targetReps, rpe: targetRpe);
}

/// An exercise's target for a session: the workout's own [base], with the
/// phase's [override] on top where it sets a field, and the RPE forced down to
/// [kDeloadRpe] on a deload pass. Volume is left alone in a deload — it is the
/// effort that comes down.
Target resolveTarget(Target base, Target? override, {required bool deload}) {
  return Target(
    sets: override?.sets ?? base.sets,
    reps: override?.reps ?? base.reps,
    rpe: deload ? kDeloadRpe : override?.rpe ?? base.rpe,
    isDeload: deload,
  );
}
