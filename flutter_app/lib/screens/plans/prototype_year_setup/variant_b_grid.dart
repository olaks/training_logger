// PROTOTYPE — throwaway. Variant B: the whole year on one screen, a matrix of
// cycle days (rows) by phases (columns). Edit any cell in place; a new phase
// starts as a copy of the last one; a day can be filled into every later
// phase. Nothing to step through — the plan is always the thing on screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/periodization.dart';
import '../phases_section.dart' show showPhaseDialog;
import 'shared.dart';

const _dayCol = 52.0;
const _phaseCol = 150.0;

class CycleGrid extends ConsumerWidget {
  final int planId;
  const CycleGrid({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref
        .watch(allPlansProvider)
        .value
        ?.where((p) => p.id == planId)
        .firstOrNull;
    final phases = ref.watch(planPhasesProvider(planId)).value ?? [];
    final sessions = ref.watch(planSessionsProvider(planId)).value ?? [];
    final name = workoutNamer(ref);
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Colors.white.withValues(alpha: 0.5);
    if (plan == null) return const Scaffold();
    final days = plan.cycleDays;
    final unit = cycleWord(days);
    final totalDays =
        phases.fold<int>(0, (n, p) => n + p.lengthPasses * days);

    List<int> cell(int phaseId, int day) => [
          for (final s in sessions)
            if (s.phaseId == phaseId && s.day == day) s.workoutId,
        ];

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        children: [
          // ── The year's shape ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '${phases.length} phases · '
                  '${(totalDays / 7).round()} weeks',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text('Cycle', style: TextStyle(color: muted)),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: days > 1
                    ? () => _setDays(context, ref, days - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$days days'),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: days < 28
                    ? () => _setDays(context, ref, days + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Each phase's share of the year.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                for (var i = 0; i < phases.length; i++)
                  Expanded(
                    flex: phases[i].lengthPasses,
                    child: Container(
                      height: 8,
                      color: primary.withValues(alpha: i.isEven ? 0.85 : 0.45),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Days × phases ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: _dayCol),
                    for (final p in phases)
                      _PhaseHeader(
                        phase: p,
                        unit: unit,
                        onEdit: () => _editPhase(context, ref, p, unit),
                      ),
                    SizedBox(
                      width: 110,
                      child: TextButton.icon(
                        onPressed: () => _addPhase(ref, phases, sessions),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Phase'),
                      ),
                    ),
                  ],
                ),
                for (var day = 1; day <= days; day++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _dayCol,
                        height: 64,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Day $day',
                              style: TextStyle(fontSize: 12, color: muted)),
                        ),
                      ),
                      for (var i = 0; i < phases.length; i++)
                        _Cell(
                          workouts: cell(phases[i].id, day).map(name).toList(),
                          onTap: () async {
                            final picked = await pickWorkouts(context, ref,
                                title: '${phases[i].name} · day $day',
                                initial: cell(phases[i].id, day));
                            if (picked == null) return;
                            await writeDay(ref.read(dbProvider), sessions,
                                phases[i].id, day, picked);
                          },
                          // Copy this day into every later phase.
                          onFillRight: i == phases.length - 1
                              ? null
                              : () async {
                                  final db = ref.read(dbProvider);
                                  final ids = cell(phases[i].id, day);
                                  for (final later in phases.skip(i + 1)) {
                                    await writeDay(
                                        db, sessions, later.id, day, ids);
                                  }
                                },
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a cell to choose that day\'s workouts. Hold it to copy the '
            'day into every later phase. A new phase starts as a copy of '
            'the last.',
            style: TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }

  Future<void> _setDays(BuildContext context, WidgetRef ref, int days) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await ref.setCycleDays(planId, days)) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Clear the last day in every phase first.')));
    }
  }

  Future<void> _editPhase(
      BuildContext context, WidgetRef ref, PlanPhase p, String unit) async {
    final r = await showPhaseDialog(context,
        title: 'Edit phase',
        unit: unit,
        initial: (name: p.name, weeks: p.lengthPasses, deloadEvery: p.deloadEvery));
    if (r == null) return;
    await ref.updatePhase(p.id,
        name: r.name, lengthPasses: r.weeks, deloadEvery: r.deloadEvery);
  }

  /// A new phase, as a copy of the last one's length, deloads and cycle.
  Future<void> _addPhase(WidgetRef ref, List<PlanPhase> phases,
      List<PhaseSession> sessions) async {
    final last = phases.lastOrNull;
    final db = ref.read(dbProvider);
    final id = await db.insertPhase(planId, 'Phase ${phases.length + 1}',
        lengthPasses: last?.lengthPasses ?? 4,
        deloadEvery: last?.deloadEvery);
    if (last == null) return;
    for (final s in sessions.where((s) => s.phaseId == last.id)) {
      await db.addSessionToPhase(id, s.workoutId, day: s.day);
    }
  }
}

class _PhaseHeader extends StatelessWidget {
  final PlanPhase phase;
  final String unit;
  final VoidCallback onEdit;
  const _PhaseHeader(
      {required this.phase, required this.unit, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final every = phase.deloadEvery;
    return SizedBox(
      width: _phaseCol,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phase.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                  '${phase.lengthPasses} ${unit}s'
                  '${every == null ? '' : ' · deload /$every'}',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final List<String> workouts;
  final VoidCallback onTap;
  final VoidCallback? onFillRight;
  const _Cell(
      {required this.workouts, required this.onTap, required this.onFillRight});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: workouts.isEmpty
            ? Colors.white.withValues(alpha: 0.03)
            : primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          onLongPress: onFillRight,
          child: SizedBox(
            width: _phaseCol - 4,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: workouts.isEmpty
                  ? Text('Rest',
                      style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.3)))
                  : Text(workouts.join('\n'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, height: 1.3)),
            ),
          ),
        ),
      ),
    );
  }
}
