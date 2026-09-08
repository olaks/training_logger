import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/load_settings_provider.dart';
import '../../utils/format_utils.dart';
import '../../utils/training_load.dart';
import 'load_zone.dart';

enum _Range { month, threeMonths, sixMonths, year, all }

/// The full training-load picture: where the acute:chronic ratio sits now,
/// how it got there, and the two load curves it is the quotient of.
class TrainingLoadScreen extends ConsumerStatefulWidget {
  const TrainingLoadScreen({super.key});

  @override
  ConsumerState<TrainingLoadScreen> createState() => _TrainingLoadScreenState();
}

class _TrainingLoadScreenState extends ConsumerState<TrainingLoadScreen> {
  _Range _range = _Range.threeMonths;

  String _rangeLabel(_Range r) => switch (r) {
        _Range.month => '1M',
        _Range.threeMonths => '3M',
        _Range.sixMonths => '6M',
        _Range.year => '1Y',
        _Range.all => 'All',
      };

  String? _cutoff() {
    final now = DateTime.now();
    return switch (_range) {
      _Range.month => dateStrFrom(DateTime(now.year, now.month - 1, now.day)),
      _Range.threeMonths =>
        dateStrFrom(DateTime(now.year, now.month - 3, now.day)),
      _Range.sixMonths =>
        dateStrFrom(DateTime(now.year, now.month - 6, now.day)),
      _Range.year => dateStrFrom(DateTime(now.year - 1, now.month, now.day)),
      _Range.all => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final series = ref.watch(loadSeriesProvider);
    final settings = ref.watch(loadSettingsProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training load'),
        actions: [
          IconButton(
            tooltip: 'How this is calculated',
            onPressed: () => context.push('/load/method'),
            icon: const Icon(Icons.help_outline, size: 20),
          ),
        ],
      ),
      body: series.isEmpty
          ? const _Empty()
          : _body(context, series, settings, primary),
    );
  }

  Widget _body(BuildContext context, LoadSeries series, LoadSettings settings,
      Color primary) {
    final cutoff = _cutoff();
    final points = cutoff == null
        ? series.points
        : series.points
            .where((p) => p.date.compareTo(cutoff) >= 0)
            .toList(growable: false);
    final latest = series.latest!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _Headline(
            point: latest,
            unit: series.metric.unit,
            historyDays: series.historyDays),
        const SizedBox(height: 20),

        // What is being counted, then how it is averaged — both change every
        // number below, so they sit above the charts rather than under them.
        _PickerLabel('Load counted as', onTap: () => context.push('/load/method')),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: LoadMetric.values
              .map((m) => ChoiceChip(
                    label:
                        Text(m.label, style: const TextStyle(fontSize: 12)),
                    selected: settings.metric == m,
                    onSelected: (_) =>
                        ref.read(loadSettingsProvider.notifier).setMetric(m),
                    selectedColor: primary.withValues(alpha: 0.25),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(settings.metric.summary,
            style: TextStyle(
                fontSize: 11.5, color: Colors.white.withValues(alpha: 0.4))),

        const SizedBox(height: 16),
        const _PickerLabel('Averaged as'),
        SegmentedButton<AcwrMethod>(
          segments: const [
            ButtonSegment(
                value: AcwrMethod.rollingAverage, label: Text('Rolling avg')),
            ButtonSegment(value: AcwrMethod.ewma, label: Text('EWMA')),
          ],
          selected: {settings.method},
          showSelectedIcon: false,
          style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12.5))),
          onSelectionChanged: (s) =>
              ref.read(loadSettingsProvider.notifier).setMethod(s.first),
        ),
        const SizedBox(height: 6),
        Text(
          settings.method == AcwrMethod.rollingAverage
              ? 'Trailing 7-day load ÷ trailing 28-day load, each day weighted '
                  'the same.'
              : 'Exponentially weighted averages — recent sessions count for '
                  'more, older ones fade out rather than dropping off.',
          style: TextStyle(
              fontSize: 11.5, color: Colors.white.withValues(alpha: 0.4)),
        ),

        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _Range.values
              .map((r) => ChoiceChip(
                    label: Text(_rangeLabel(r),
                        style: const TextStyle(fontSize: 12)),
                    selected: _range == r,
                    onSelected: (_) => setState(() => _range = r),
                    selectedColor: primary.withValues(alpha: 0.25),
                  ))
              .toList(),
        ),

        const SizedBox(height: 20),
        _ChartTitle(
          'Acute : chronic ratio',
          'Shaded band is the 0.8–1.3 sweet spot.',
        ),
        SizedBox(height: 200, child: _RatioChart(points: points)),

        const SizedBox(height: 24),
        _ChartTitle(
          'Acute vs chronic load',
          'Both as 7-day figures, in ${series.metric.unit}, so they are '
              'directly comparable.',
        ),
        SizedBox(
            height: 200, child: _LoadChart(points: points, primary: primary)),

        const SizedBox(height: 24),
        _MethodLink(series: series),
      ],
    );
  }
}

// ── Headline block ───────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  final AcwrPoint point;
  final String unit;
  final int historyDays;
  const _Headline(
      {required this.point, required this.unit, required this.historyDays});

  @override
  Widget build(BuildContext context) {
    final zone = point.zone;
    final faint = Colors.white.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formatRatio(point.ratio),
              style: TextStyle(
                fontSize: 44,
                height: 1,
                fontWeight: FontWeight.bold,
                color: zone.color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                zone.label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: zone.color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ZoneGauge(ratio: point.ratio, height: 10),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final t in ['0', '0.8', '1.3', '1.5', '2.0+'])
              Flexible(
                child: Text(t,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 10, color: faint)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(zone.advice,
            style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.7))),
        if (point.baselineIsPartial) ...[
          const SizedBox(height: 8),
          _Caveat(
            'Only $historyDays days of history — the 28-day baseline is still '
            'filling in, so the ratio will swing more than it should.',
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _Stat(
                    label: 'This week',
                    value: formatLoad(point.acute),
                    unit: unit)),
            Expanded(
                child: _Stat(
                    label: 'Baseline',
                    value: formatLoad(point.chronic),
                    unit: unit)),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _Stat({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 2),
          Text('$value $unit',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      );
}

// ── Charts ───────────────────────────────────────────────────────────────────

class _ChartTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ChartTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      );
}

/// Shared axis setup — the two charts sit above one another and read as one
/// picture, so they label their x-axis identically.
FlTitlesData _titles(List<AcwrPoint> points, String Function(double) leftLabel) {
  Widget faintText(String s) => Text(s,
      style: TextStyle(
          fontSize: 9.5, color: Colors.white.withValues(alpha: 0.45)));

  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (v, meta) =>
            v == meta.max ? const SizedBox.shrink() : faintText(leftLabel(v)),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 26,
        interval: points.length > 6 ? (points.length / 5).ceilToDouble() : 1,
        getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= points.length) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: faintText(points[i].date.substring(5)),
          );
        },
      ),
    ),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

FlGridData get _grid => FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) =>
          FlLine(color: Colors.white.withValues(alpha: 0.06), strokeWidth: 1),
    );

class _RatioChart extends StatelessWidget {
  final List<AcwrPoint> points;
  const _RatioChart({required this.points});

  @override
  Widget build(BuildContext context) {
    // Days without a baseline have no ratio to plot; the line simply starts
    // where one exists.
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        if (points[i].ratio != null) FlSpot(i.toDouble(), points[i].ratio!),
    ];
    if (spots.length < 2) return const _NotEnough();

    final maxRatio = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: (maxRatio * 1.15).clamp(1.8, double.infinity),
        gridData: _grid,
        borderData: FlBorderData(show: false),
        titlesData: _titles(points, (v) => v.toStringAsFixed(1)),
        rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
          HorizontalRangeAnnotation(
            y1: 0.8,
            y2: 1.3,
            color: LoadZone.optimal.color.withValues(alpha: 0.13),
          ),
          HorizontalRangeAnnotation(
            y1: 1.5,
            y2: 100,
            color: LoadZone.spike.color.withValues(alpha: 0.10),
          ),
        ]),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            color: Colors.white.withValues(alpha: 0.85),
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2C2C2E),
            getTooltipItems: (touched) => touched.map((s) {
              final p = points[s.x.toInt()];
              return LineTooltipItem(
                '${p.date.substring(5)}\n',
                TextStyle(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                children: [
                  TextSpan(
                    text: formatRatio(p.ratio),
                    style: TextStyle(
                        color: p.zone.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  TextSpan(
                    text: '  ${p.zone.label}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _LoadChart extends StatelessWidget {
  final List<AcwrPoint> points;
  final Color primary;
  const _LoadChart({required this.points, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const _NotEnough();

    final acute = <FlSpot>[];
    final chronic = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      acute.add(FlSpot(i.toDouble(), points[i].acute));
      chronic.add(FlSpot(i.toDouble(), points[i].chronic));
    }
    final maxY = [...acute, ...chronic]
        .map((s) => s.y)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: 0,
              maxY: maxY <= 0 ? 1 : maxY * 1.15,
              gridData: _grid,
              borderData: FlBorderData(show: false),
              titlesData: _titles(points, formatLoad),
              lineBarsData: [
                LineChartBarData(
                  spots: acute,
                  isCurved: false,
                  barWidth: 2,
                  color: primary,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: primary.withValues(alpha: 0.10)),
                ),
                LineChartBarData(
                  spots: chronic,
                  isCurved: false,
                  barWidth: 1.5,
                  dashArray: const [5, 4],
                  color: Colors.white.withValues(alpha: 0.45),
                  dotData: const FlDotData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF2C2C2E),
                  getTooltipItems: (touched) => touched.map((s) {
                    final isAcute = s.barIndex == 0;
                    return LineTooltipItem(
                      '${isAcute ? "acute" : "baseline"} '
                      '${formatLoad(s.y)}',
                      TextStyle(
                        color: isAcute
                            ? primary
                            : Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Key(color: primary, label: 'Acute (7 days)'),
            const SizedBox(width: 16),
            _Key(
                color: Colors.white.withValues(alpha: 0.45),
                label: 'Chronic baseline',
                dashed: true),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _Key({required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 14,
              height: dashed ? 1.5 : 2.5,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        ],
      );
}

class _NotEnough extends StatelessWidget {
  const _NotEnough();

  @override
  Widget build(BuildContext context) => Center(
        child: Text('Not enough days in this range yet.',
            style: TextStyle(
                fontSize: 12.5, color: Colors.white.withValues(alpha: 0.35))),
      );
}

// ── Link out to the full explanation ─────────────────────────────────────────

class _PickerLabel extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _PickerLabel(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = Text(text,
        style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4)));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: onTap == null
          ? label
          : Row(
              children: [
                label,
                const Spacer(),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                  child: const Text('How this works',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
    );
  }
}

/// The way into the long explanation, carrying whichever caveats actually
/// apply to this log so they are not buried a screen away.
class _MethodLink extends StatelessWidget {
  final LoadSeries series;
  const _MethodLink({required this.series});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final rpePct = (series.rpeCoverage * 100).round();
    final caveats = <String>[
      if (series.metric != LoadMetric.volume)
        rpePct == 0
            ? 'No RPE logged yet, so every set counts at RPE '
                '${kNeutralRpe.toInt()}.'
            : '$rpePct% of your sets carry an RPE; the rest count at '
                '${kNeutralRpe.toInt()}.',
      if (series.usedAssumedBodyWeight)
        'Some bodyweight work has no weigh-in behind it, so '
            '${kAssumedBodyWeightKg.toInt()} kg stood in.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/load/method'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 18, color: primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How this is calculated',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: primary)),
                        const SizedBox(height: 2),
                        Text(
                          'What the ratio means, what counts as load, and '
                          'where the number stops being trustworthy.',
                          style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: Colors.white.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 20, color: Colors.white.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ),
        ),
        for (final c in caveats) ...[
          const SizedBox(height: 8),
          _Caveat(c),
        ],
      ],
    );
  }
}

class _Caveat extends StatelessWidget {
  final String text;
  const _Caveat(this.text);

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 11.5, height: 1.35, color: color)),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Log some sets and your acute:chronic workload ratio will build '
            'up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
      );
}
