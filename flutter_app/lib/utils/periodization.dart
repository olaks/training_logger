import '../database/database.dart';
import 'format_utils.dart';

/// Where a periodized plan stands, replayed from its event log.
///
/// A plan runs its phases in order. A phase lasts a number of *passes* — one
/// trip through its rotation of sessions, which the UI calls a week — so
/// missed days never move the plan; only logged sessions do. Nothing about the
/// position is stored: everything here is a pure function of the phases, their
/// rotations and the events, so it can be tested without a database, and undo
/// or editing a phase mid-plan just means replaying again.

/// The target RPE for every exercise during a deload pass.
const kDeloadRpe = 5;

/// How many passes ahead a scheduled deload can be and still be the one a
/// "deload now" takes early. Any further off and the manual deload is extra.
const kDeloadReplaceWindow = 2;

/// The position of a plan, as [resolvePlan] works it out.
class PlanState {
  /// The phase being worked through, or null once the plan is over.
  final PlanPhase? phase;

  /// 1-based pass within [phase].
  final int pass;

  /// Passes of [phase] finished so far. Unlike [pass], not capped at
  /// [totalPasses]: a finished phase keeps counting while it waits.
  final int passesDone;

  /// Passes in [phase], including any deloads inserted by hand.
  final int totalPasses;

  /// Sessions done and skipped in [phase] so far, every one logged — a
  /// session repeated within its pass counts again here, though it does
  /// nothing for the pass.
  final int sessionsDone;
  final int sessionsSkipped;

  /// Sessions of the current pass not yet done or skipped, in rotation order.
  final List<int> remaining;

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
    required this.passesDone,
    required this.totalPasses,
    required this.sessionsDone,
    required this.sessionsSkipped,
    required this.remaining,
    required this.isDeload,
    required this.passesUntilDeload,
    required this.deloads,
    required this.phaseComplete,
    required this.planComplete,
  });
}

/// Replays [events] against [phases] (in any order; sorted by `sortOrder`)
/// and their [rotations] (phase id → workout ids in rotation order).
PlanState resolvePlan(
  List<PlanPhase> phases,
  Map<int, List<int>> rotations,
  List<PlanEvent> events,
) {
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
    return const PlanState(
      phase: null,
      pass: 0,
      passesDone: 0,
      totalPasses: 0,
      sessionsDone: 0,
      sessionsSkipped: 0,
      remaining: [],
      isDeload: false,
      passesUntilDeload: null,
      deloads: [],
      phaseComplete: false,
      planComplete: true,
    );
  }

  final rotation = rotations[current.id] ?? const <int>[];
  var total = current.lengthPasses;
  // 1-based passes that are deloads: the phase's rule first, then reshaped by
  // each "deload now" as it comes.
  final every = current.deloadEvery;
  var deloads = <int>{
    if (every != null && every > 0)
      for (var p = every; p <= total; p += every) p,
  };
  var passesDone = 0;
  var sessionsDone = 0;
  var sessionsSkipped = 0;
  final covered = <int>{};
  var started = false;
  for (final e in log.where((e) => e.phaseId == current.id)) {
    switch (e.kind) {
      case PlanEventKind.done:
      case PlanEventKind.skip:
        if (e.kind == PlanEventKind.done) {
          sessionsDone++;
        } else {
          sessionsSkipped++;
        }
        // Each session carries the pass it was recorded in, and whether it
        // finished that pass. Both stand whatever the rotation has become
        // since: a later stamp means every pass before it was finished, an
        // earlier one belongs to a pass that is already behind.
        final stamp = e.pass ?? passesDone + 1;
        if (stamp < passesDone + 1) continue;
        if (stamp > passesDone + 1) {
          passesDone = stamp - 1;
          covered.clear();
        }
        started = true;
        // A session outside the rotation (or whose workout is gone) still
        // starts its pass, but doesn't bring it any closer to done.
        if (rotation.contains(e.workoutId)) covered.add(e.workoutId!);
        if (e.closesPass || rotation.every(covered.contains)) {
          passesDone++;
          covered.clear();
          started = false;
        }
      case PlanEventKind.deload:
        // The deload goes on the first pass not yet started.
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

  // Sessions done after the last pass are kept rather than capped, so that
  // lengthening a finished phase credits them.
  final complete = passesDone >= total;
  final pass = complete ? total : passesDone + 1;
  final upcoming = deloads.where((p) => p >= pass).toList()..sort();
  return PlanState(
    phase: current,
    pass: pass,
    passesDone: passesDone,
    totalPasses: total,
    sessionsDone: sessionsDone,
    sessionsSkipped: sessionsSkipped,
    remaining: [
      for (final w in rotation)
        if (!covered.contains(w)) w,
    ],
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
/// a pass is taken to last a week, which is what the UI calls it.
const kPaceMinSessions = 3;

/// The shortest a one-session pass is projected to take, whatever the pace.
/// A rotation of a single session is that session once a week, not as often
/// as the athlete trains; a longer rotation runs at the pace it is trained.
const kMinPassDays = 7;

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
  /// measure one and every pass was taken as a week.
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
/// [resolvePlan] does. Only sessions (done or skipped) move a plan, so the
/// pace is the sessions logged per day lately, and a pass takes as long as
/// its rotation does at that pace.
PlanProjection projectPlan(
  List<PlanPhase> phases,
  Map<int, List<int>> rotations,
  List<PlanEvent> events,
  DateTime today,
) {
  today = _day(today);
  final state = resolvePlan(phases, rotations, events);
  final ordered = [...phases]
    ..sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
  final perDay = _sessionsPerDay(events, today);

  double passDays(int rotationLength) {
    if (perDay == null || rotationLength == 0) return 7;
    final days = rotationLength / perDay;
    return rotationLength == 1 && days < kMinPassDays
        ? kMinPassDays.toDouble()
        : days;
  }
  DateTime after(double days) =>
      today.add(Duration(days: days.round()));

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
    final rotation = rotations[p.id]?.length ?? 0;
    final pass = passDays(rotation);

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
      // What is left of the pass under way, as a fraction of a pass, then
      // the passes after it.
      final partial = state.phaseComplete
          ? 0.0
          : rotation == 0
              ? 1.0
              : state.remaining.length / rotation;
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

/// Sessions done or skipped per day over the last [kPaceWindowDays] days up
/// to [today], or since the first one if that is more recent — though never
/// over fewer than seven days, so that one busy weekend isn't the pace.
double? _sessionsPerDay(List<PlanEvent> events, DateTime today) {
  final days = [
    for (final e in events)
      if (e.kind == PlanEventKind.done || e.kind == PlanEventKind.skip)
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
