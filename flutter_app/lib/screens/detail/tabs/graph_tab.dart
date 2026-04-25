import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/grades.dart';

class GraphTab extends ConsumerWidget {
  final int categoryId;
  const GraphTab({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync  = ref.watch(setsForCategoryProvider(categoryId));
    final catAsync   = ref.watch(categoryByIdProvider(categoryId));
    final isClimbing = catAsync.value?.exerciseType == 1;

    return setsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('$e')),
      data: (sets) {
        if (sets.isEmpty) {
          return Center(
            child: Text('No data yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35))),
          );
        }
        return _Graph(sets: sets, isClimbing: isClimbing);
      },
    );
  }
}

class _Graph extends StatefulWidget {
  final List<WorkoutSet> sets;
  final bool isClimbing;
  const _Graph({required this.sets, required this.isClimbing});

  @override
  State<_Graph> createState() => _GraphState();
}

enum _Metric { weight, oneRM, volume, reps, time, grade }

class _GraphState extends State<_Graph> {
  _Metric _metric = _Metric.weight;
  List<String> _gradeScale = fontGrades;

  @override
  void initState() {
    super.initState();
    if (widget.isClimbing) {
      _gradeScale = _detectScale();
      _metric = _Metric.grade;
    } else {
      _metric = _autoMetric(widget.sets);
    }
  }

  @override
  void didUpdateWidget(_Graph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isClimbing) {
      // Re-detect scale: if user logs V-grades after only Font grades (or vice
      // versa), grade indices need to map to the new scale.
      final newScale = _detectScale();
      if (!identical(newScale, _gradeScale)) {
        setState(() => _gradeScale = newScale);
      }
    } else if (!_metricAvailable(_metric)) {
      // Selected metric became unavailable (e.g. last weight set was deleted).
      setState(() => _metric = _autoMetric(widget.sets));
    }
  }

  List<String> _detectScale() => detectGradeScale(
      widget.sets.where((s) => s.grade != null).map((s) => s.grade!));

  static _Metric _autoMetric(List<WorkoutSet> sets) {
    if (sets.any((s) => (s.weightKg ?? 0) != 0)) return _Metric.weight;
    if (sets.any((s) => (s.reps ?? 0) > 0))      return _Metric.reps;
    return _Metric.time;
  }

  static double _epley(double w, int reps) => w * (1 + reps / 30);

  List<({String date, double value})> _buildPoints(_Metric metric) {
    final grouped = <String, List<WorkoutSet>>{};
    for (final s in widget.sets) {
      grouped.putIfAbsent(s.dateStr, () => []).add(s);
    }
    final dates = grouped.keys.toList()..sort();
    final points = <({String date, double value})>[];

    for (final d in dates) {
      final daySets = grouped[d]!;
      double value;

      switch (metric) {
        case _Metric.weight:
          value = daySets
              .map((s) => s.weightKg ?? 0.0)
              .reduce((a, b) => a > b ? a : b);
        case _Metric.reps:
          value = daySets.fold(0, (sum, s) => sum + (s.reps ?? 0));
        case _Metric.time:
          value = daySets.fold(0, (sum, s) => sum + (s.timeSecs ?? 0));
        case _Metric.volume:
          value = daySets.fold(0.0,
              (sum, s) => sum + (s.weightKg ?? 0) * (s.reps ?? 0));
          if (value == 0) continue;
        case _Metric.oneRM:
          final eligible = daySets
              .where((s) => (s.weightKg ?? 0) > 0 && (s.reps ?? 0) > 0);
          if (eligible.isEmpty) continue;
          value = eligible
              .map((s) => _epley(s.weightKg!, s.reps!))
              .reduce((a, b) => a > b ? a : b);
        case _Metric.grade:
          final idxs = daySets
              .where((s) => s.grade != null)
              .map((s) => gradeToIndex(s.grade!, _gradeScale))
              .where((i) => i >= 0);
          if (idxs.isEmpty) continue;
          value = idxs.reduce((a, b) => a > b ? a : b).toDouble();
      }

      points.add((date: d, value: value));
    }
    return points;
  }

  String _metricLabel(_Metric m) => switch (m) {
        _Metric.weight => 'Max Weight',
        _Metric.oneRM  => 'Est. 1RM',
        _Metric.volume => 'Volume',
        _Metric.reps   => 'Total Reps',
        _Metric.time   => 'Total Time',
        _Metric.grade  => 'Best Grade',
      };

  bool _metricAvailable(_Metric m) => switch (m) {
        _Metric.weight => widget.sets.any((s) => (s.weightKg ?? 0) != 0),
        _Metric.oneRM  => widget.sets
            .any((s) => (s.weightKg ?? 0) > 0 && (s.reps ?? 0) > 0),
        _Metric.volume => widget.sets
            .any((s) => (s.weightKg ?? 0) > 0 && (s.reps ?? 0) > 0),
        _Metric.reps   => widget.sets.any((s) => (s.reps ?? 0) > 0),
        _Metric.time   => widget.sets.any((s) => (s.timeSecs ?? 0) > 0),
        _Metric.grade  => widget.sets.any((s) => s.grade != null),
      };

  String _formatValue(double v) => switch (_metric) {
        _Metric.time  => formatTime(v.toInt()),
        _Metric.reps  => '${v.toInt()} reps',
        _Metric.weight => '${formatWeight(v)} kg',
        _Metric.oneRM  => '${formatWeight(v)} kg',
        _Metric.volume => '${formatWeight(v)} kg·reps',
        _Metric.grade  => _gradeScale[v.toInt().clamp(0, _gradeScale.length - 1)],
      };

  @override
  Widget build(BuildContext context) {
    final points  = _buildPoints(_metric);
    final primary = Theme.of(context).colorScheme.primary;

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final minY  = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY  = spots.isEmpty ? 1.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).clamp(1.0, double.infinity);

    // For grade axis: snap to integer ticks, show grade strings
    final isGrade = _metric == _Metric.grade;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric chips — hide for climbing (only one metric)
          if (!widget.isClimbing) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _Metric.values
                  .where((m) => m != _Metric.grade)
                  .map((m) {
                final available = _metricAvailable(m);
                return ChoiceChip(
                  label: Text(_metricLabel(m),
                      style: const TextStyle(fontSize: 12)),
                  selected: _metric == m,
                  onSelected:
                      available ? (_) => setState(() => _metric = m) : null,
                  selectedColor: primary.withValues(alpha: 0.25),
                  disabledColor: Colors.white.withValues(alpha: 0.05),
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              _metricLabel(_Metric.grade),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary),
            ),
          ],

          if (_metric == _Metric.oneRM || _metric == _Metric.volume) ...[
            const SizedBox(height: 6),
            Text(
              _metric == _Metric.oneRM
                  ? 'Epley formula · best set per session'
                  : 'Sum of weight × reps across all sets',
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.35)),
            ),
          ],

          const SizedBox(height: 16),

          if (points.length < 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Log more sessions to see a graph.',
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.35))),
            ),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: isGrade
                    ? (minY - 1).clamp(0, double.infinity)
                    : minY - range * 0.1,
                maxY: isGrade ? maxY + 1 : maxY + range * 0.15,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withValues(alpha: 0.07),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isGrade ? 52 : 48,
                      interval: isGrade ? 1 : null,
                      getTitlesWidget: (val, meta) {
                        if (isGrade) {
                          final idx = val.round();
                          if (idx < 0 || idx >= _gradeScale.length) {
                            return const SizedBox.shrink();
                          }
                          // Only label every other grade to avoid crowding
                          if (idx % 2 != 0) return const SizedBox.shrink();
                          return Text(_gradeScale[idx],
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.45)));
                        }
                        return Text(
                          _metric == _Metric.time
                              ? formatTime(val.toInt())
                              : val % 1 == 0
                                  ? val.toInt().toString()
                                  : val.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.45)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: points.length > 8
                          ? (points.length / 6).ceilToDouble()
                          : 1,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < 0 || i >= points.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            points[i].date.substring(5), // MM-DD
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.45)),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots:    spots,
                    isCurved: false,
                    color:    primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: primary,
                        strokeWidth: 2,
                        strokeColor: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2C2C2E),
                    getTooltipItems: (touchedSpots) =>
                        touchedSpots.map((s) {
                      final i  = s.x.toInt();
                      final pt = points[i];
                      return LineTooltipItem(
                        '${pt.date.substring(5)}\n',
                        TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11),
                        children: [
                          TextSpan(
                            text: _formatValue(pt.value),
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          if (_metric == _Metric.oneRM)
                            TextSpan(
                              text: ' est.',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
