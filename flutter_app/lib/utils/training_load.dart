import '../database/database.dart';
import 'body_weight.dart';
import 'grades.dart';

/// Training load, and the acute:chronic workload ratio built on top of it.
///
/// ACWR compares what you did this week (the *acute* load) against what you
/// have been doing lately (the *chronic* load). Ramp the acute week far above
/// the chronic baseline and you are training harder than your body has been
/// prepared for; sit far below it and you are detraining. The ratio is only as
/// good as the load number underneath it, so that is defined first.
///
/// The arithmetic is deliberately kept out of the widget layer: everything
/// below is plain functions over logged rows, so the ratio can be tested
/// without a database or a widget tree.

// ── Load model ───────────────────────────────────────────────────────────────

/// RPE that counts as "normal hard work", and so scales load by exactly 1.
///
/// Sets without a recorded RPE are assumed to sit here. Anchoring the neutral
/// point mid-scale rather than at 10 means logging RPE sharpens the number in
/// both directions instead of only ever dragging it down.
const kNeutralRpe = 7.0;

/// Seconds of time-under-tension that count as one rep. A hang, a plank or a
/// lock-off is loaded work with no rep count, so it is converted to
/// rep-equivalents to share an axis with everything else.
const kSecondsPerRep = 3.0;

/// Rep-equivalents credited to the easiest climb on the scale. Every grade
/// step above it adds one more, so a Font 7A (six steps above 6A) costs six
/// rep-equivalents more than the 6A does.
const kClimbBaseReps = 4.0;

/// Stand-in body weight for bodyweight work logged before any weigh-in exists.
///
/// Without it every pull-up and dead hang would score zero load. It biases the
/// absolute numbers, but ACWR is a ratio of load against load, so a consistent
/// stand-in largely cancels out.
const kAssumedBodyWeightKg = 70.0;

/// A way of turning logged sets into a single daily load figure.
///
/// There is no one right answer here — the sports-science literature runs on
/// session-RPE, while strength training conventionally counts volume — so the
/// choice is the athlete's. All three agree on the *shape* of a set: how many
/// rep-equivalents it was, and how many kilograms each of those moved.
enum LoadMetric {
  /// Kilograms moved, times repetitions. Ignores how hard it felt, so it is
  /// only ever as honest as the assumption that heavier means harder — but it
  /// needs nothing beyond what every logged set already carries.
  volume,

  /// Volume, scaled by RPE where one was recorded. Uses the whole history the
  /// way [volume] does, and sharpens as RPE coverage grows — at the cost of
  /// the metric shifting meaning somewhat while that happens.
  rpeWeightedVolume,

  /// Effort × work done, ignoring absolute weight: the closest this app's data
  /// gets to the session-RPE figure the ACWR literature is built on. Sets
  /// logged without an RPE are counted at [kNeutralRpe].
  sessionRpe;

  String get label => switch (this) {
        LoadMetric.volume => 'Volume',
        LoadMetric.rpeWeightedVolume => 'Volume × RPE',
        LoadMetric.sessionRpe => 'Session RPE',
      };

  String get unit => switch (this) {
        LoadMetric.volume || LoadMetric.rpeWeightedVolume => 'kg·reps',
        LoadMetric.sessionRpe => 'RPE·reps',
      };

  /// One line, for the picker.
  String get summary => switch (this) {
        LoadMetric.volume => 'Weight moved × reps. Ignores RPE entirely.',
        LoadMetric.rpeWeightedVolume =>
          'Volume, scaled by RPE where you logged one.',
        LoadMetric.sessionRpe =>
          'RPE × reps. Ignores how heavy the weight was.',
      };
}

/// The two things every set reduces to before a metric is applied: how much
/// work was done, and how heavily it was loaded.
typedef _Work = ({double reps, double kgPerRep});

/// Load contributed by a single logged set, under [metric].
///
/// The three set shapes the app records each reduce to rep-equivalents and a
/// per-rep load:
///
///  * **weighted reps** — the reps as logged, at the logged weight. A set with
///    reps but no weight is bodyweight work, so the body is the load.
///  * **timed work** — a hang or hold has no rep count, so its time becomes
///    `time / [kSecondsPerRep]` rep-equivalents, each carrying body weight
///    plus whatever was added (negative for band assistance).
///  * **climbs** — no weight or reps are recorded, so a climb is body weight
///    for a rep-equivalent count that rises with the grade.
double setLoad({
  required bool isClimbing,
  required LoadMetric metric,
  double? weightKg,
  int? reps,
  int? timeSecs,
  int? rpe,
  String? grade,
  required double bodyWeightKg,
  List<String> gradeScale = fontGrades,
}) {
  final work = isClimbing
      ? _climbWork(grade, gradeScale, bodyWeightKg)
      : _standardWork(weightKg, reps, timeSecs, bodyWeightKg);
  if (work.reps <= 0 || work.kgPerRep <= 0) return 0;

  final logged = (rpe != null && rpe > 0) ? rpe.toDouble() : null;
  return switch (metric) {
    LoadMetric.volume => work.kgPerRep * work.reps,
    LoadMetric.rpeWeightedVolume =>
      work.kgPerRep * work.reps * ((logged ?? kNeutralRpe) / kNeutralRpe),
    LoadMetric.sessionRpe => work.reps * (logged ?? kNeutralRpe),
  };
}

_Work _standardWork(
    double? weightKg, int? reps, int? timeSecs, double bodyWeightKg) {
  final added = weightKg ?? 0;
  if (timeSecs != null && timeSecs > 0) {
    // Body weight is what a hang actually loads; `added` moves it either way.
    return (reps: timeSecs / kSecondsPerRep, kgPerRep: bodyWeightKg + added);
  }
  if (reps == null || reps <= 0) return (reps: 0, kgPerRep: 0);
  // An external weight is the whole load; without one the body is the load.
  return (reps: reps.toDouble(), kgPerRep: added != 0 ? added : bodyWeightKg);
}

_Work _climbWork(String? grade, List<String> scale, double bodyWeightKg) {
  if (grade == null) return (reps: 0, kgPerRep: 0);
  final idx = gradeToIndex(grade, scale);
  return (
    reps: kClimbBaseReps + (idx < 0 ? 0 : idx),
    kgPerRep: bodyWeightKg,
  );
}

// ── Daily series ─────────────────────────────────────────────────────────────

/// Load for one calendar day, and how it compares to the recent past.
class AcwrPoint {
  /// `yyyy-MM-dd`.
  final String date;

  /// Load logged on this day alone. Zero on rest days.
  final double load;

  /// This week's load: the trailing 7 days, including [date].
  final double acute;

  /// The recent baseline, expressed as a comparable 7-day figure so [ratio]
  /// is a like-for-like comparison against [acute].
  final double chronic;

  /// `acute / chronic`, or null while there is no baseline to divide by.
  final double? ratio;

  /// True until 28 days of history exist, while [chronic] is still averaging
  /// over a short window and the ratio swings on very little evidence.
  final bool baselineIsPartial;

  const AcwrPoint({
    required this.date,
    required this.load,
    required this.acute,
    required this.chronic,
    required this.ratio,
    required this.baselineIsPartial,
  });

  LoadZone get zone => zoneFor(ratio);
}

/// Where a ratio sits against the conventional ACWR bands.
enum LoadZone {
  /// No baseline yet, so no ratio to place.
  unknown,

  /// Under 0.8 — training below what the body is prepared for.
  detraining,

  /// 0.8–1.3, the "sweet spot": progressing at a rate the baseline supports.
  optimal,

  /// 1.3–1.5 — ramping faster than the baseline justifies.
  caution,

  /// Above 1.5 — the spike range the ratio exists to catch.
  spike,
}

LoadZone zoneFor(double? ratio) {
  if (ratio == null) return LoadZone.unknown;
  if (ratio < 0.8) return LoadZone.detraining;
  if (ratio <= 1.3) return LoadZone.optimal;
  if (ratio <= 1.5) return LoadZone.caution;
  return LoadZone.spike;
}

/// How the chronic baseline is derived.
enum AcwrMethod {
  /// Unweighted rolling averages — the original Gabbett formulation: the
  /// trailing 7-day total over the trailing 28-day total ÷ 4. Easy to reason
  /// about, but every day in the window counts the same, so a load drops out
  /// of the baseline abruptly on its 29th day.
  rollingAverage,

  /// Exponentially weighted moving averages, which decay older sessions
  /// smoothly instead of dropping them off a cliff. Better behaved when
  /// training is intermittent, which is the usual case here.
  ewma,
}

const _acuteDays = 7;
const _chronicDays = 28;

/// The full day-by-day series from the first logged day through [today].
///
/// Rest days are filled in as zero load — leaving them out would let a week
/// off look identical to a week of training, which is exactly the signal ACWR
/// is meant to carry.
List<AcwrPoint> acwrSeries(
  Map<String, double> loadByDate, {
  required DateTime today,
  AcwrMethod method = AcwrMethod.rollingAverage,
}) {
  if (loadByDate.isEmpty) return const [];

  final sortedDates = loadByDate.keys.toList()..sort();
  final end = DateTime(today.year, today.month, today.day);
  final first = _parse(sortedDates.first);
  if (end.isBefore(first)) return const [];

  // Calendar-safe day stepping: adding a Duration would skip or repeat an
  // hour across a DST boundary, and these are dates, not instants.
  final days = <String>[];
  final loads = <double>[];
  for (var d = first; !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1)) {
    final key = _dateStr(d);
    days.add(key);
    loads.add(loadByDate[key] ?? 0);
  }

  return method == AcwrMethod.rollingAverage
      ? _rollingAverageSeries(days, loads)
      : _ewmaSeries(days, loads);
}

List<AcwrPoint> _rollingAverageSeries(List<String> days, List<double> loads) {
  // Prefix sums keep both window totals to a subtraction per day.
  final prefix = List<double>.filled(loads.length + 1, 0);
  for (var i = 0; i < loads.length; i++) {
    prefix[i + 1] = prefix[i] + loads[i];
  }
  double windowSum(int i, int span) =>
      prefix[i + 1] - prefix[(i - span + 1).clamp(0, i + 1)];

  return [
    for (var i = 0; i < days.length; i++) _point(
      date: days[i],
      load: loads[i],
      acute: windowSum(i, _acuteDays),
      // Before 28 days of history the window is short, so average over the
      // days that exist rather than pretending the missing ones were rest.
      // Dividing a partial sum by a full 4 weeks would understate the
      // baseline and inflate every early ratio.
      chronic: windowSum(i, _chronicDays) /
          ((i + 1).clamp(1, _chronicDays) / _acuteDays),
      elapsedDays: i + 1,
    ),
  ];
}

List<AcwrPoint> _ewmaSeries(List<String> days, List<double> loads) {
  // The standard smoothing constant for an N-day EWMA.
  const acuteLambda = 2 / (_acuteDays + 1);
  const chronicLambda = 2 / (_chronicDays + 1);

  var acute = loads.first;
  var chronic = loads.first;
  final points = <AcwrPoint>[];
  for (var i = 0; i < days.length; i++) {
    if (i > 0) {
      acute = loads[i] * acuteLambda + acute * (1 - acuteLambda);
      chronic = loads[i] * chronicLambda + chronic * (1 - chronicLambda);
    }
    // Both averages are per-day, so they compare directly. Scaling to weekly
    // totals keeps the figures on the same footing as the rolling-average
    // method, and cancels out of the ratio.
    points.add(_point(
      date: days[i],
      load: loads[i],
      acute: acute * _acuteDays,
      chronic: chronic * _acuteDays,
      elapsedDays: i + 1,
    ));
  }
  return points;
}

AcwrPoint _point({
  required String date,
  required double load,
  required double acute,
  required double chronic,
  required int elapsedDays,
}) =>
    AcwrPoint(
      date: date,
      load: load,
      acute: acute,
      chronic: chronic,
      ratio: chronic > 0 ? acute / chronic : null,
      baselineIsPartial: elapsedDays < _chronicDays,
    );

/// A computed series plus the context needed to read it honestly.
class LoadSeries {
  final List<AcwrPoint> points;

  /// The metric these loads were counted under — which is what [AcwrPoint.load]
  /// and the two window figures are denominated in.
  final LoadMetric metric;

  /// Share of contributing sets that carried an RPE, 0–1. The load metric
  /// leans on RPE where it exists, so this is how much of it is effort-scaled.
  final double rpeCoverage;

  /// True when no weigh-in was available and [kAssumedBodyWeightKg] stood in
  /// for bodyweight work.
  final bool usedAssumedBodyWeight;

  const LoadSeries({
    required this.points,
    required this.metric,
    required this.rpeCoverage,
    required this.usedAssumedBodyWeight,
  });

  static const empty = LoadSeries(
      points: [],
      metric: LoadMetric.rpeWeightedVolume,
      rpeCoverage: 0,
      usedAssumedBodyWeight: false);

  bool get isEmpty => points.isEmpty;

  AcwrPoint? get latest => points.isEmpty ? null : points.last;

  /// Days of history behind the latest point, which is what decides whether
  /// the chronic baseline has had time to mean anything.
  int get historyDays => points.length;
}

// ── Formatting ───────────────────────────────────────────────────────────────

/// Compact load figure. Volume loads run to six digits, which is more
/// precision than a glanceable card can use.
String formatLoad(double v) {
  final a = v.abs();
  if (a >= 100000) return '${(v / 1000).round()}k';
  if (a >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
  if (a >= 1000) return '${(v / 1000).toStringAsFixed(2)}k';
  return v.round().toString();
}

String formatRatio(double? r) => r == null ? '—' : r.toStringAsFixed(2);

// Local copies so this file stays free of the wider utils graph.
String _dateStr(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _parse(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

// ── Building a series from logged rows ───────────────────────────────────────

/// Turns everything logged into a day-by-day ACWR series.
///
/// [categories] supplies each set's exercise type — climbs and lifts reduce to
/// load by different routes — and [bodyWeights] the weigh-in to assume for
/// bodyweight work on the day the set was logged. [metric] decides what the
/// resulting numbers actually count.
LoadSeries buildLoadSeries(
  List<WorkoutSet> sets,
  List<ExerciseCategory> categories,
  List<BodyWeight> bodyWeights, {
  required DateTime today,
  LoadMetric metric = LoadMetric.rpeWeightedVolume,
  AcwrMethod method = AcwrMethod.rollingAverage,
}) {
  if (sets.isEmpty) return LoadSeries.empty;

  final climbingIds = {
    for (final c in categories)
      if (c.exerciseType == 1) c.id,
  };
  // One scale for the whole history: a set's grade means the same thing on
  // the chart wherever it was logged.
  final scale = detectGradeScale(
      sets.where((s) => s.grade != null).map((s) => s.grade!));
  final lookup = BodyWeightLookup(bodyWeights);

  final byDate = <String, double>{};
  var contributing = 0;
  var withRpe = 0;
  var leanedOnAssumedWeight = false;

  for (final s in sets) {
    final logged = lookup.on(s.dateStr);
    final isClimbing = climbingIds.contains(s.categoryId);
    // Only note the fallback when it actually carried a set's load: an
    // externally weighted lift never consults body weight.
    final needsBodyWeight =
        isClimbing || (s.timeSecs ?? 0) > 0 || (s.weightKg ?? 0) == 0;
    if (logged == null && needsBodyWeight) leanedOnAssumedWeight = true;

    final load = setLoad(
      isClimbing: isClimbing,
      metric: metric,
      weightKg: s.weightKg,
      reps: s.reps,
      timeSecs: s.timeSecs,
      rpe: s.rpe,
      grade: s.grade,
      bodyWeightKg: logged ?? kAssumedBodyWeightKg,
      gradeScale: scale,
    );
    if (load <= 0) continue;

    byDate[s.dateStr] = (byDate[s.dateStr] ?? 0) + load;
    contributing++;
    if ((s.rpe ?? 0) > 0) withRpe++;
  }

  return LoadSeries(
    points: acwrSeries(byDate, today: today, method: method),
    metric: metric,
    rpeCoverage: contributing == 0 ? 0 : withRpe / contributing,
    usedAssumedBodyWeight: leanedOnAssumedWeight,
  );
}
