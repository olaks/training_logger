import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/grades.dart';
import 'package:training_logger/utils/training_load.dart';

/// `yyyy-MM-dd` for `day` days after 2026-01-01.
String day(int n) {
  final d = DateTime(2026, 1, 1 + n);
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

DateTime dayTime(int n) => DateTime(2026, 1, 1 + n);

/// A run of days all carrying the same load.
Map<String, double> flat(int days, double load, {int from = 0}) => {
      for (var i = 0; i < days; i++) day(from + i): load,
    };

WorkoutSet aSet({
  int categoryId = 1,
  String dateStr = '2026-01-01',
  double? weightKg,
  int? reps,
  int? timeSecs,
  int? rpe,
  String? grade,
}) =>
    WorkoutSet(
      id: 0,
      categoryId: categoryId,
      dateStr: dateStr,
      timestamp: 0,
      weightKg: weightKg,
      reps: reps,
      timeSecs: timeSecs,
      rpe: rpe,
      grade: grade,
    );

void main() {
  group('setLoad', () {
    test('weighted reps are weight times reps', () {
      expect(
        setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, weightKg: 80, reps: 5, bodyWeightKg: 75),
        400,
      );
    });

    test('reps with no weight are carried by body weight', () {
      expect(
        setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, reps: 10, bodyWeightKg: 75),
        750,
      );
    });

    test('a hang counts body weight plus what is added, over time', () {
      // (75 + 15) kg for 30 s = 10 rep-equivalents.
      expect(
        setLoad(
            isClimbing: false,
            metric: LoadMetric.rpeWeightedVolume,
            weightKg: 15,
            timeSecs: 30,
            bodyWeightKg: 75),
        900,
      );
    });

    test('assistance below body weight lightens a hang without going negative',
        () {
      final assisted = setLoad(
          isClimbing: false,
          metric: LoadMetric.rpeWeightedVolume,
          weightKg: -20,
          timeSecs: 30,
          bodyWeightKg: 75);
      final unassisted =
          setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, timeSecs: 30, bodyWeightKg: 75);
      expect(assisted, lessThan(unassisted));
      expect(assisted, greaterThan(0));

      // More assistance than body weight is not negative work.
      expect(
        setLoad(
            isClimbing: false,
            metric: LoadMetric.rpeWeightedVolume,
            weightKg: -100,
            timeSecs: 30,
            bodyWeightKg: 75),
        0,
      );
    });

    test('a harder climb costs more than an easier one', () {
      final sixA = setLoad(
          isClimbing: true,
          metric: LoadMetric.rpeWeightedVolume,
          grade: '6A',
          bodyWeightKg: 75,
          gradeScale: fontGrades);
      final sevenA = setLoad(
          isClimbing: true,
          metric: LoadMetric.rpeWeightedVolume,
          grade: '7A',
          bodyWeightKg: 75,
          gradeScale: fontGrades);
      expect(sixA, greaterThan(0));
      // 7A is six grade steps above 6A, so six rep-equivalents dearer.
      expect(sevenA - sixA, 6 * 75);
    });

    test('an unrecognised grade still counts as a climb', () {
      expect(
        setLoad(isClimbing: true, metric: LoadMetric.rpeWeightedVolume, grade: 'V4', bodyWeightKg: 75),
        kClimbBaseReps * 75,
      );
    });

    test('RPE scales the set, with 7 leaving it untouched', () {
      const base = 400.0;
      expect(
        setLoad(
            isClimbing: false,
            metric: LoadMetric.rpeWeightedVolume,
            weightKg: 80,
            reps: 5,
            rpe: 7,
            bodyWeightKg: 75),
        base,
      );
      expect(
        setLoad(
            isClimbing: false,
            metric: LoadMetric.rpeWeightedVolume,
            weightKg: 80,
            reps: 5,
            rpe: 10,
            bodyWeightKg: 75),
        closeTo(base * 10 / 7, 0.001),
      );
      // No RPE reads the same as a neutral one, rather than as zero effort.
      expect(
        setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, weightKg: 80, reps: 5, bodyWeightKg: 75),
        base,
      );
    });

    test('a set with nothing logged contributes nothing', () {
      expect(setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, bodyWeightKg: 75), 0);
      expect(setLoad(isClimbing: false, metric: LoadMetric.rpeWeightedVolume, reps: 0, bodyWeightKg: 75), 0);
      expect(setLoad(isClimbing: true, metric: LoadMetric.rpeWeightedVolume, bodyWeightKg: 75), 0);
    });
  });

  group('LoadMetric', () {
    // One set, read three ways: 80 kg × 5 reps at RPE 10.
    double under(LoadMetric m, {int? rpe}) => setLoad(
          isClimbing: false,
          metric: m,
          weightKg: 80,
          reps: 5,
          rpe: rpe,
          bodyWeightKg: 75,
        );

    test('volume ignores RPE entirely', () {
      expect(under(LoadMetric.volume, rpe: 10), 400);
      expect(under(LoadMetric.volume, rpe: 4), 400);
      expect(under(LoadMetric.volume), 400);
    });

    test('RPE-weighted volume scales by effort around the neutral point', () {
      expect(under(LoadMetric.rpeWeightedVolume, rpe: 7), 400);
      expect(under(LoadMetric.rpeWeightedVolume, rpe: 10),
          closeTo(400 * 10 / 7, 1e-9));
      expect(under(LoadMetric.rpeWeightedVolume), 400,
          reason: 'no RPE counts as neutral');
    });

    test('session RPE counts effort and reps, not kilograms', () {
      expect(under(LoadMetric.sessionRpe, rpe: 10), 50);
      // Doubling the bar changes nothing; doubling the reps doubles the load.
      expect(
        setLoad(
            isClimbing: false,
            metric: LoadMetric.sessionRpe,
            weightKg: 160,
            reps: 5,
            rpe: 10,
            bodyWeightKg: 75),
        50,
      );
      expect(under(LoadMetric.sessionRpe), 5 * kNeutralRpe);
    });

    test('a set with no work in it is zero under every metric', () {
      for (final m in LoadMetric.values) {
        expect(setLoad(isClimbing: false, metric: m, bodyWeightKg: 75), 0,
            reason: m.name);
      }
    });

    test('each metric names the unit it is denominated in', () {
      expect(LoadMetric.volume.unit, 'kg·reps');
      expect(LoadMetric.rpeWeightedVolume.unit, 'kg·reps');
      expect(LoadMetric.sessionRpe.unit, 'RPE·reps');
    });
  });

  group('acwrSeries — rolling average', () {
    test('steady training sits at 1.0', () {
      final s = acwrSeries(flat(35, 100), today: dayTime(34));
      expect(s.last.acute, 700);
      expect(s.last.chronic, 700);
      expect(s.last.ratio, closeTo(1.0, 1e-9));
      expect(s.last.zone, LoadZone.optimal);
    });

    test('tripling the week triples the ratio against a flat baseline', () {
      final loads = {...flat(28, 100), ...flat(7, 300, from: 28)};
      final s = acwrSeries(loads, today: dayTime(34));

      // Acute is the last seven days; the 28-day window still holds 21 easy
      // days, so the baseline has only partly caught up.
      expect(s.last.acute, 2100);
      expect(s.last.chronic, closeTo(1050, 1e-9));
      expect(s.last.ratio, closeTo(2.0, 1e-9));
      expect(s.last.zone, LoadZone.spike);
    });

    test('rest days count as zero, not as missing', () {
      // One session, then three weeks off.
      final s = acwrSeries({day(0): 1000}, today: dayTime(21));
      expect(s.length, 22);
      expect(s.last.acute, 0);
      expect(s.last.chronic, greaterThan(0));
      expect(s.last.ratio, 0);
      expect(s.last.zone, LoadZone.detraining);
    });

    test('a partial baseline averages the days that exist', () {
      final s = acwrSeries(flat(7, 100), today: dayTime(6));
      // Seven days of history: the baseline is that one week, so the ratio is
      // 1.0 rather than the 4.0 that dividing by a full 28 days would give.
      expect(s.last.chronic, closeTo(700, 1e-9));
      expect(s.last.ratio, closeTo(1.0, 1e-9));
      expect(s.last.baselineIsPartial, isTrue);
    });

    test('the baseline stops being partial once 28 days are behind it', () {
      final s = acwrSeries(flat(30, 100), today: dayTime(29));
      expect(s[26].baselineIsPartial, isTrue);
      expect(s[27].baselineIsPartial, isFalse);
    });

    test('no baseline yields no ratio rather than a division by zero', () {
      final s = acwrSeries({day(0): 0.0, day(1): 100}, today: dayTime(1));
      expect(s.first.ratio, isNull);
      expect(s.first.zone, LoadZone.unknown);
      expect(s.last.ratio, isNotNull);
    });

    test('the series runs from the first logged day to today', () {
      final s = acwrSeries({day(0): 100}, today: dayTime(9));
      expect(s.length, 10);
      expect(s.first.date, day(0));
      expect(s.last.date, day(9));
    });

    test('an empty log produces an empty series', () {
      expect(acwrSeries({}, today: dayTime(0)), isEmpty);
    });

    test('a log that starts after today produces nothing to plot', () {
      expect(acwrSeries({day(5): 100}, today: dayTime(0)), isEmpty);
    });
  });

  group('acwrSeries — EWMA', () {
    test('steady training sits at 1.0', () {
      final s = acwrSeries(flat(60, 100),
          today: dayTime(59), method: AcwrMethod.ewma);
      expect(s.last.ratio, closeTo(1.0, 0.02));
    });

    test('a spike lifts the ratio above the sweet spot', () {
      final loads = {...flat(60, 100), ...flat(7, 400, from: 60)};
      final s = acwrSeries(loads,
          today: dayTime(66), method: AcwrMethod.ewma);
      expect(s.last.ratio, greaterThan(1.5));
      expect(s.last.zone, LoadZone.spike);
    });

    test('older sessions fade rather than dropping off a cliff', () {
      // One hard day, then nothing at all.
      final loads = {day(0): 1000.0};
      final ewma =
          acwrSeries(loads, today: dayTime(40), method: AcwrMethod.ewma);
      final ra = acwrSeries(loads, today: dayTime(40));

      // The rolling window loses that day whole on its 29th day, taking the
      // baseline — and with it any ratio at all — with it.
      expect(ra[27].chronic, greaterThan(0));
      expect(ra[28].chronic, 0);
      expect(ra[28].ratio, isNull);

      // EWMA bleeds it off instead, and still has a baseline to divide by.
      expect(ewma[20].chronic, lessThan(ewma[10].chronic));
      expect(ewma[28].chronic, greaterThan(0));
      expect(ewma[28].ratio, isNotNull);
    });
  });

  group('zoneFor', () {
    test('bands split at 0.8, 1.3 and 1.5', () {
      expect(zoneFor(null), LoadZone.unknown);
      expect(zoneFor(0.79), LoadZone.detraining);
      expect(zoneFor(0.8), LoadZone.optimal);
      expect(zoneFor(1.3), LoadZone.optimal);
      expect(zoneFor(1.31), LoadZone.caution);
      expect(zoneFor(1.5), LoadZone.caution);
      expect(zoneFor(1.51), LoadZone.spike);
    });
  });

  group('buildLoadSeries', () {
    final lifting = const ExerciseCategory(id: 1, name: 'Bench', exerciseType: 0);
    final climbing =
        const ExerciseCategory(id: 2, name: 'Bouldering', exerciseType: 1);

    test('sets logged on the same day are added together', () {
      final s = buildLoadSeries(
        [
          aSet(dateStr: day(0), weightKg: 80, reps: 5),
          aSet(dateStr: day(0), weightKg: 80, reps: 5),
        ],
        [lifting],
        [],
        today: dayTime(0),
      );
      expect(s.points.single.load, 800);
    });

    test("an exercise's type decides how its sets are read", () {
      final s = buildLoadSeries(
        [aSet(categoryId: 2, dateStr: day(0), grade: '6A')],
        [lifting, climbing],
        [BodyWeight(dateStr: day(0), kg: 70)],
        today: dayTime(0),
      );
      // 6A is index 5 on the Font scale: (4 + 5) rep-equivalents at 70 kg.
      expect(s.points.single.load, closeTo(70 * 9, 1e-9));
      expect(s.usedAssumedBodyWeight, isFalse);
    });

    test('the nearest earlier weigh-in carries bodyweight work', () {
      final s = buildLoadSeries(
        [aSet(dateStr: day(5), reps: 10)],
        [lifting],
        [BodyWeight(dateStr: day(0), kg: 80)],
        today: dayTime(5),
      );
      expect(s.points.last.load, 800);
    });

    test('bodyweight work without any weigh-in falls back, and says so', () {
      final s = buildLoadSeries(
        [aSet(dateStr: day(0), reps: 10)],
        [lifting],
        [],
        today: dayTime(0),
      );
      expect(s.points.single.load, kAssumedBodyWeightKg * 10);
      expect(s.usedAssumedBodyWeight, isTrue);
    });

    test('an externally weighted lift never needs a weigh-in', () {
      final s = buildLoadSeries(
        [aSet(dateStr: day(0), weightKg: 80, reps: 5)],
        [lifting],
        [],
        today: dayTime(0),
      );
      expect(s.usedAssumedBodyWeight, isFalse);
    });

    test('RPE coverage counts only sets that contributed load', () {
      final s = buildLoadSeries(
        [
          aSet(dateStr: day(0), weightKg: 80, reps: 5, rpe: 8),
          aSet(dateStr: day(0), weightKg: 80, reps: 5),
          // Logged with nothing measurable, so it is not part of the metric.
          aSet(dateStr: day(0)),
        ],
        [lifting],
        [],
        today: dayTime(0),
      );
      expect(s.rpeCoverage, 0.5);
    });

    test('the chosen metric carries through to the series', () {
      final sets = [aSet(dateStr: day(0), weightKg: 80, reps: 5, rpe: 10)];
      final volume = buildLoadSeries(sets, [lifting], [],
          today: dayTime(0), metric: LoadMetric.volume);
      final srpe = buildLoadSeries(sets, [lifting], [],
          today: dayTime(0), metric: LoadMetric.sessionRpe);

      expect(volume.metric, LoadMetric.volume);
      expect(volume.points.single.load, 400);
      expect(srpe.points.single.load, 50);
    });

    test('nothing logged gives an empty series, not a zero ratio', () {
      final s = buildLoadSeries([], [lifting], [], today: dayTime(0));
      expect(s.isEmpty, isTrue);
      expect(s.latest, isNull);
    });
  });

  group('formatLoad', () {
    test('keeps big volumes glanceable', () {
      expect(formatLoad(420), '420');
      expect(formatLoad(4210), '4.21k');
      expect(formatLoad(42100), '42.1k');
      expect(formatLoad(421000), '421k');
    });
  });
}
