import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/periodization.dart';
import '../../utils/undo_snackbar.dart';

/// Where the running periodized plan stands, at the top of today's view:
/// the phase, cycle and day, how far off the next deload is, a rest day and
/// the way out of it, and — once every cycle of a phase is done — the choice
/// between moving on and adding another.
class PlanBanner extends ConsumerWidget {
  final ActivePlan active;
  final String dateStr;
  const PlanBanner({super.key, required this.active, required this.dateStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = active.state;
    final phase = s.phase!;
    final primary = Theme.of(context).colorScheme.primary;
    final color = s.isDeload ? Colors.amber : primary;

    final unit = cycleWord(s.cycleDays);
    final headline = [
      '${phase.name} · $unit ${s.pass}/${s.totalPasses}',
      if (!s.phaseComplete && s.cycleDays > 1) 'day ${s.day}/${s.cycleDays}',
      if (s.isDeload)
        'deload, RPE $kDeloadRpe'
      else if (!s.phaseComplete && s.passesUntilDeload != null)
        'deload in ${s.passesUntilDeload}',
    ].join(' · ');

    final dim =
        TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(headline,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: color)),
                ),
                PopupMenuButton<_BannerAction>(
                  icon: Icon(Icons.more_vert,
                      size: 20, color: Colors.white.withValues(alpha: 0.4)),
                  onSelected: (a) => switch (a) {
                    _BannerAction.deload => _deloadNow(context, ref),
                    _BannerAction.open =>
                      context.push('/plans/${active.plan.id}'),
                  },
                  itemBuilder: (_) => [
                    if (!s.isDeload && !s.phaseComplete)
                      const PopupMenuItem(
                          value: _BannerAction.deload,
                          child: Text('Deload now')),
                    PopupMenuItem(
                        value: _BannerAction.open,
                        child: Text('Open ${active.plan.name}')),
                  ],
                ),
              ],
            ),
            if (s.phaseComplete)
              _PhaseDone(active: active, dateStr: dateStr)
            else if (s.isRestDay)
              Row(
                children: [
                  Expanded(
                    child: Text(
                        s.due == null
                            ? 'Rest day.'
                            : 'Rest day. Or train day ${s.due!.day} now '
                                'instead.',
                        style: dim),
                  ),
                  TextButton(
                    onPressed: () => _skipRest(context, ref),
                    child: const Text('Skip rest day'),
                  ),
                ],
              )
            else
              Text(workoutsLeftLine(s, DateTime.now()), style: dim),
          ],
        ),
      ),
    );
  }

  Future<void> _skipRest(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(dbProvider);
    final event = await db.skipRestDay(dateStr);
    if (event == null) return;
    showUndoSnackBar(messenger,
        message: 'Rest day skipped',
        onUndo: () => db.deletePlanEvent(event.id));
  }

  Future<void> _deloadNow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    // The banner can be rebuilt away before the undo is tapped.
    final db = ref.read(dbProvider);
    final event = await db.deloadNow(dateStr);
    if (event == null) return;
    showUndoSnackBar(messenger,
        message: 'Deload coming up',
        onUndo: () => db.deletePlanEvent(event.id));
  }
}

enum _BannerAction { deload, open }

class _PhaseDone extends ConsumerWidget {
  final ActivePlan active;
  final String dateStr;
  const _PhaseDone({required this.active, required this.dateStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = active.state.phase!;
    final next = active.nextPhase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 6),
          child: Text(
            next == null
                ? '${phase.name} is done, and with it the plan.'
                : '${phase.name} is done. Move on, or add another '
                    '${cycleWord(active.plan.cycleDays)} if it is still '
                    'paying off?',
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: () => ref.advancePhase(dateStr),
              child: Text(next == null ? 'Finish plan' : 'Start ${next.name}'),
            ),
            OutlinedButton(
              onPressed: () => ref.updatePhase(phase.id,
                  name: phase.name,
                  lengthPasses: phase.lengthPasses + 1,
                  deloadEvery: phase.deloadEvery),
              child: Text('Add a ${cycleWord(active.plan.cycleDays)}'),
            ),
          ],
        ),
      ],
    );
  }
}
