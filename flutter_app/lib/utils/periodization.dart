import '../database/database.dart';

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

  /// Passes in [phase], including any deloads inserted by hand.
  final int totalPasses;

  /// Sessions of the current pass not yet done or skipped, in rotation order.
  final List<int> remaining;

  /// The current pass is a deload: every target drops to [kDeloadRpe].
  final bool isDeload;

  /// Passes from the current one to the next deload in [phase]: 0 while in
  /// one, null when none is left.
  final int? passesUntilDeload;

  /// Every pass of [phase] is done; waiting for the athlete to move on.
  final bool phaseComplete;

  final bool planComplete;

  const PlanState({
    required this.phase,
    required this.pass,
    required this.totalPasses,
    required this.remaining,
    required this.isDeload,
    required this.passesUntilDeload,
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
      totalPasses: 0,
      remaining: [],
      isDeload: false,
      passesUntilDeload: null,
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
  final covered = <int>{};
  for (final e in log.where((e) => e.phaseId == current.id)) {
    switch (e.kind) {
      case PlanEventKind.done:
      case PlanEventKind.skip:
        // A session outside the rotation, or one already covered this pass,
        // doesn't bring the pass any closer to done.
        if (!rotation.contains(e.workoutId)) continue;
        covered.add(e.workoutId!);
        if (covered.length == rotation.toSet().length) {
          passesDone++;
          covered.clear();
        }
      case PlanEventKind.deload:
        // The deload goes on the first pass not yet started.
        final target = passesDone + (covered.isEmpty ? 1 : 2);
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
    totalPasses: total,
    remaining: [
      for (final w in rotation)
        if (!covered.contains(w)) w,
    ],
    isDeload: !complete && deloads.contains(pass),
    passesUntilDeload:
        complete || upcoming.isEmpty ? null : upcoming.first - pass,
    phaseComplete: complete,
    planComplete: false,
  );
}

/// What an exercise is planned to be: any field may be unset.
class Target {
  final int? sets;
  final int? reps;
  final int? rpe;
  final bool isDeload;

  const Target({this.sets, this.reps, this.rpe, this.isDeload = false});
}

/// An exercise's target for a session: the workout's own [base], with the
/// phase's [override] on top where it sets a field, and the RPE forced down to
/// [kDeloadRpe] on a deload pass. Volume is left alone in a deload — it is the
/// effort that comes down.
Target resolveTarget(Target base, PhaseExerciseTarget? override,
    {required bool deload}) {
  return Target(
    sets: override?.targetSets ?? base.sets,
    reps: override?.targetReps ?? base.reps,
    rpe: deload ? kDeloadRpe : override?.targetRpe ?? base.rpe,
    isDeload: deload,
  );
}
