import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../utils/periodization.dart';

/// Where a phased plan's phases fall in time: the ones behind as they ran,
/// the rest estimated from the pace of recent sessions. A plan that isn't
/// running is laid out as if it were started (or resumed) today.
class TimelineSection extends ConsumerWidget {
  final int planId;
  const TimelineSection({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = ref.watch(planPhasesProvider(planId)).value ?? [];
    final sessions = ref.watch(planSessionsProvider(planId)).value ?? [];
    final events = ref.watch(planEventsProvider(planId)).value ?? [];
    final running = ref.watch(activePlanProvider).value?.plan.id == planId;
    if (phases.isEmpty) return const SizedBox.shrink();

    final cycleDays = ref
            .watch(allPlansProvider)
            .value
            ?.where((p) => p.id == planId)
            .firstOrNull
            ?.cycleDays ??
        8;
    final now = DateTime.now();
    final projection = projectPlan(phases, cyclesOf(phases, sessions), events,
        cycleDays: cycleDays, today: now);
    final state = projection.state;

    final primary = Theme.of(context).colorScheme.primary;
    final muted = Colors.white.withValues(alpha: 0.5);
    // A plan that has never run has nothing under way yet.
    final current = running || events.isNotEmpty ? state.phase?.id : null;
    final today = DateTime.utc(now.year, now.month, now.day);
    String date(DateTime d) =>
        DateFormat(d.year == now.year ? 'MMM d' : 'MMM d, y').format(d);

    final pace = projection.sessionsPerWeek;
    final paceLine = pace == null
        ? 'A ${cycleWord(cycleDays)} at a time, until a few sessions give '
            'a pace'
        : 'At ${pace.toStringAsFixed(1)} sessions a week, '
            'from the last $kPaceWindowDays days';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TIMELINE',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: primary)),
          const SizedBox(height: 6),
          Text(
              state.planComplete
                  ? 'Finished ${date(projection.end!)}'
                  : running
                      ? 'Ends around ${date(projection.end!)}'
                      : events.isEmpty
                          ? 'If started today, ends around '
                              '${date(projection.end!)}'
                          : 'If resumed today, ends around '
                              '${date(projection.end!)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Text(paceLine, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 10),
          _TimelineBar(
            projection: projection,
            currentPhaseId: current,
            today: today,
          ),
          const SizedBox(height: 8),
          for (final p in projection.phases)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(p.phase.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: p.finished ? muted : null,
                            fontWeight: p.phase.id == current
                                ? FontWeight.w600
                                : null)),
                  ),
                  if (p.deloads.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                          p.deloads.length == 1
                              ? 'deload ~${date(p.deloads.single)}'
                              : '${p.deloads.length} deloads',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.amber)),
                    ),
                  // An estimate is marked with ~; a day from the log isn't.
                  Text(
                      '${p.started ? '' : '~'}${date(p.start)} – '
                      '${p.finished ? '' : '~'}${date(p.end)}',
                      style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The phases as segments along one bar, in proportion to their length,
/// with deloads ticked in amber and today marked.
class _TimelineBar extends StatelessWidget {
  final PlanProjection projection;
  final int? currentPhaseId;
  final DateTime today;

  const _TimelineBar({
    required this.projection,
    required this.currentPhaseId,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final from = projection.phases.first.start;
    final span = projection.end!.difference(from).inDays;
    // A plan laid out over a single day still gets a visible bar.
    final days = span < 1 ? 1 : span;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      double x(DateTime d) =>
          (d.difference(from).inDays / days).clamp(0.0, 1.0) * width;

      return SizedBox(
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final p in projection.phases)
              Positioned(
                left: x(p.start),
                width: (x(p.end) - x(p.start)).clamp(2.0, width),
                top: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.only(right: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.centerLeft,
                  // Behind: a dim fill. Under way: solid. Ahead: only an
                  // outline, since it hasn't happened yet.
                  decoration: BoxDecoration(
                    color: p.finished
                        ? primary.withValues(alpha: 0.2)
                        : p.phase.id == currentPhaseId
                            ? primary.withValues(alpha: 0.85)
                            : null,
                    border: p.finished || p.phase.id == currentPhaseId
                        ? null
                        : Border.all(color: primary.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(p.phase.name,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white
                              .withValues(alpha: p.finished ? 0.5 : 1))),
                ),
              ),
            for (final p in projection.phases)
              for (final d in p.deloads)
                Positioned(
                  left: x(d),
                  width: 3,
                  top: 0,
                  bottom: 0,
                  child: const ColoredBox(color: Colors.amber),
                ),
            if (!today.isBefore(from) && !today.isAfter(projection.end!))
              Positioned(
                left: x(today) - 1,
                width: 2,
                top: -4,
                bottom: -4,
                child: const ColoredBox(color: Colors.white),
              ),
          ],
        ),
      );
    });
  }
}
