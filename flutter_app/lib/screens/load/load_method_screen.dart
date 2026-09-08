import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../providers/load_settings_provider.dart';
import '../../utils/training_load.dart';
import 'load_zone.dart';

/// The long form of what the load screen is showing: what the ratio is, how a
/// day's load is arrived at, and where the number stops being trustworthy.
///
/// The metric and averaging pickers live here too rather than only on the
/// chart screen — the choice makes far more sense next to the explanation of
/// what each option actually counts.
class LoadMethodScreen extends ConsumerWidget {
  const LoadMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(loadSettingsProvider);
    final series = ref.watch(loadSeriesProvider);
    final notifier = ref.read(loadSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('How load is calculated')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const _Body(
            'Training load asks a single question of every session: how much '
            'work was that? Add up the answers over the last 7 days and you '
            'have your acute load — this week. Average them over the last 28 '
            'and you have your chronic load — the workload your body has '
            'actually been prepared for.',
          ),
          const _Body(
            'The acute:chronic workload ratio is one divided by the other. At '
            '1.0 this week looks like the weeks behind it. Well above, and you '
            'are asking for more than you have built up to.',
          ),

          const _Heading('The bands'),
          for (final zone in [
            LoadZone.detraining,
            LoadZone.optimal,
            LoadZone.caution,
            LoadZone.spike,
          ])
            _ZoneRow(zone: zone),
          const SizedBox(height: 8),
          const _Body(
            'The 0.8–1.3 "sweet spot" comes from Gabbett\'s work on team-sport '
            'injury rates. It is a guide, not a law: the bands were drawn from '
            'squad-level data, and the ratio has been argued over ever since. '
            'Read a spike as a prompt to look at the week, not as a verdict.',
          ),

          const _Heading('What counts as load'),
          const _Body(
            'Three reasonable answers, and the choice changes every figure on '
            'the load screen. Whichever you pick, the sets underneath are read '
            'the same way.',
          ),
          const SizedBox(height: 4),
          for (final metric in LoadMetric.values)
            _Choice(
              title: metric.label,
              subtitle: metric.summary,
              detail: _metricDetail(metric),
              selected: settings.metric == metric,
              onTap: () => notifier.setMetric(metric),
            ),

          const _Heading('How a set becomes reps and kilograms'),
          const _Row('Weighted reps', 'the reps logged, at the weight logged'),
          const _Row('Bodyweight reps', 'the reps logged, at your body weight'),
          _Row('Hangs and holds',
              'seconds ÷ ${kSecondsPerRep.toInt()} reps, at body weight + added'),
          _Row('Climbs',
              '${kClimbBaseReps.toInt()} reps + 1 per grade step, at body weight'),
          const SizedBox(height: 8),
          const _Body(
            'Band assistance is logged as negative weight, so it lightens a '
            'hang rather than counting against you. Body weight comes from '
            'your nearest earlier weigh-in.',
          ),

          const _Heading('Averaging'),
          const _Body(
            'Both methods compare the same two windows. They disagree about '
            'how a session ages out of the baseline.',
          ),
          const SizedBox(height: 4),
          for (final method in AcwrMethod.values)
            _Choice(
              title: method == AcwrMethod.rollingAverage
                  ? 'Rolling average'
                  : 'EWMA',
              subtitle: method == AcwrMethod.rollingAverage
                  ? 'Every day in the window counts the same.'
                  : 'Recent days count for more; older ones fade.',
              detail: method == AcwrMethod.rollingAverage
                  ? 'The original formulation: this week\'s total over the '
                      'last four weeks\' average. Simple to reason about, but '
                      'a hard session counts fully for 28 days and then not at '
                      'all, which can move the ratio on a day you did nothing.'
                  : 'Exponentially weighted averages decay old sessions '
                      'smoothly instead. Generally better behaved when '
                      'training is intermittent, and what most of the newer '
                      'literature prefers.',
              selected: settings.method == method,
              onTap: () => notifier.setMethod(method),
            ),

          const _Heading('Where it gets shaky'),
          const _Bullet(
            'The first 28 days have no full baseline to compare against, so '
            'early ratios swing on very little.',
          ),
          const _Bullet(
            'Rest days count as zero — which is the point — but a long layoff '
            'drives the baseline towards nothing, and the first session back '
            'then reads as an enormous spike.',
          ),
          const _Bullet(
            'Load is only what you logged. Sessions you did not record are '
            'rest as far as this screen knows.',
          ),
          if (settings.metric != LoadMetric.volume)
            _Bullet(
              series.rpeCoverage == 0
                  ? 'You have not logged any RPE yet, so every set is being '
                      'counted at RPE ${kNeutralRpe.toInt()}.'
                  : '${(series.rpeCoverage * 100).round()}% of your sets carry '
                      'an RPE; the rest are counted at ${kNeutralRpe.toInt()}. '
                      'The metric shifts meaning somewhat as that share grows.',
            ),
          if (series.usedAssumedBodyWeight)
            _Bullet(
              'Some bodyweight work has no weigh-in behind it, so '
              '${kAssumedBodyWeightKg.toInt()} kg stood in. Logging your body '
              'weight makes those sets exact.',
            ),
        ],
      ),
    );
  }

  static String _metricDetail(LoadMetric m) => switch (m) {
        LoadMetric.volume =>
          'load = kilograms × reps. Nothing else. The conventional strength '
              'figure, and the one that needs least of you — but it cannot '
              'tell a comfortable set from one taken to failure.',
        LoadMetric.rpeWeightedVolume =>
          'load = kilograms × reps × RPE ÷ ${kNeutralRpe.toInt()}. Sets '
              'logged without an RPE are counted at ${kNeutralRpe.toInt()}, so '
              'they pass through unchanged. Uses your whole history now and '
              'gets sharper the more RPE you log.',
        LoadMetric.sessionRpe =>
          'load = reps × RPE. Ignores how heavy the weight was, which is what '
              'the ACWR research is built on — but on a log without much RPE '
              'in it, most sets fall back to ${kNeutralRpe.toInt()} and the '
              'metric becomes little more than a rep count.',
      };
}

// ── Pieces ───────────────────────────────────────────────────────────────────

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            )),
      );
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.75))),
      );
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 10),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle),
              ),
            ),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.7))),
            ),
          ],
        ),
      );
}

class _Row extends StatelessWidget {
  final String what;
  final String how;
  const _Row(this.what, this.how);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 118,
              child: Text(what,
                  style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.7))),
            ),
            Expanded(
              child: Text(how,
                  style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.45))),
            ),
          ],
        ),
      );
}

class _ZoneRow extends StatelessWidget {
  final LoadZone zone;
  const _ZoneRow({required this.zone});

  static String _range(LoadZone z) => switch (z) {
        LoadZone.detraining => 'below 0.8',
        LoadZone.optimal => '0.8 – 1.3',
        LoadZone.caution => '1.3 – 1.5',
        LoadZone.spike => 'above 1.5',
        LoadZone.unknown => '',
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 34,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                  color: zone.color, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(zone.label,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: zone.color)),
                      const SizedBox(width: 8),
                      Text(_range(zone),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(zone.advice,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.55))),
                ],
              ),
            ),
          ],
        ),
      );
}

/// A selectable option with its full explanation attached, so choosing and
/// understanding are the same act.
class _Choice extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  const _Choice({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? primary.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? primary.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 17,
                      color:
                          selected ? primary : Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected ? primary : null)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 6),
                Text(detail,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.45))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
