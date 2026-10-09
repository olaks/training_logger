import '../database/database.dart';
import 'periodization.dart';

/// A periodized plan as the setup guide edits it: the year's shape, one
/// template cycle, and per phase either that template or its own copy.
/// Nothing here touches the database until [AppDatabase.applyPlanSetup]
/// writes it, so the guide can be abandoned at any step.

/// One phase being set up.
class PhaseDraft {
  /// The phase it edits, or null for one the guide adds.
  final int? id;
  String name;
  int cycles;
  int? deloadEvery;

  /// Its own cycle, or null to run the template.
  Cycle? own;

  PhaseDraft(this.name, this.cycles, this.deloadEvery, {this.id, this.own});
}

class PlanSetup {
  int cycleDays;
  Cycle template;
  List<PhaseDraft> phases;

  PlanSetup({
    required this.cycleDays,
    required this.template,
    required this.phases,
  });

  /// The plan as it stands. Its first phase's cycle is the template, and a
  /// phase gets its own copy only where it differs. A plan with no phases
  /// starts from [classicYear], on an empty template.
  factory PlanSetup.fromPlan(
      Plan plan, List<PlanPhase> phases, List<PhaseSession> sessions) {
    final ordered = [...phases]
      ..sort((x, y) => x.sortOrder.compareTo(y.sortOrder));
    if (ordered.isEmpty) {
      return PlanSetup(
          cycleDays: plan.cycleDays, template: {}, phases: classicYear());
    }
    final cycles = cyclesOf(ordered, sessions);
    final template = copyCycle(cycles[ordered.first.id]!);
    return PlanSetup(
      cycleDays: plan.cycleDays,
      template: template,
      phases: [
        for (final p in ordered)
          PhaseDraft(p.name, p.lengthPasses, p.deloadEvery,
              id: p.id,
              own: sameCycle(cycles[p.id]!, template)
                  ? null
                  : copyCycle(cycles[p.id]!)),
      ],
    );
  }

  /// The cycle [phase] will run.
  Cycle cycleOf(PhaseDraft phase) => phase.own ?? template;

  /// Days the whole plan takes when every day is trained on the day it is up.
  int get totalDays => phases.fold(0, (n, p) => n + p.cycles * cycleDays);
}

/// The year most plans start from: building capacity, then strength, then
/// peaking, with a deload every few cycles.
List<PhaseDraft> classicYear() => [
      PhaseDraft('Capacity', 8, 4),
      PhaseDraft('Basic strength', 10, 4),
      PhaseDraft('Max strength', 8, 3),
      PhaseDraft('Peak', 4, null),
    ];

Cycle copyCycle(Cycle c) => {
      for (final MapEntry(:key, :value) in c.entries)
        if (value.isNotEmpty) key: [...value],
    };

/// Whether [a] and [b] hold the same workouts on the same days, in order.
bool sameCycle(Cycle a, Cycle b) {
  final days = {...a.keys, ...b.keys};
  return days.every((d) {
    final x = a[d] ?? const <int>[], y = b[d] ?? const <int>[];
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  });
}

/// Days of [cycle] with workouts.
int trainingDays(Cycle cycle) =>
    cycle.values.where((w) => w.isNotEmpty).length;
