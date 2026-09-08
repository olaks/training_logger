import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../utils/training_load.dart';
import 'load_zone.dart';

/// The Home-screen glance at training load: where this week sits against the
/// recent baseline, and a way through to the full picture.
///
/// Renders nothing at all until something is logged — a ratio computed from
/// no history would be noise dressed up as a number.
class LoadSummaryCard extends ConsumerWidget {
  const LoadSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(loadSeriesProvider);
    final point = series.latest;
    if (point == null) return const SizedBox.shrink();

    final zone = point.zone;
    final faint = Colors.white.withValues(alpha: 0.4);

    return Card(
      child: InkWell(
        onTap: () => context.push('/load'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 16, color: faint),
                  const SizedBox(width: 6),
                  Text('TRAINING LOAD',
                      style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: faint)),
                  const Spacer(),
                  Text(
                    formatRatio(point.ratio),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: zone.color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: faint),
                ],
              ),
              const SizedBox(height: 8),
              ZoneGauge(ratio: point.ratio),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    point.baselineIsPartial ? 'Building baseline' : zone.label,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: point.baselineIsPartial ? faint : zone.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '7d ${formatLoad(point.acute)}  ·  '
                      'baseline ${formatLoad(point.chronic)}',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: faint),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
