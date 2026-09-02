import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/utils/body_weight.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<BodyWeightLookup> lookupOf(Map<String, double> weighIns) async {
    for (final e in weighIns.entries) {
      await db.saveBodyWeight(e.key, e.value);
    }
    return BodyWeightLookup(await db.watchBodyWeights().first);
  }

  group('BodyWeightLookup', () {
    test('carries the most recent weigh-in forward', () async {
      final bw = await lookupOf({'2026-01-01': 70, '2026-03-01': 72});

      expect(bw.on('2026-01-01'), 70);
      expect(bw.on('2026-02-14'), 70, reason: 'nothing newer logged yet');
      expect(bw.on('2026-03-01'), 72);
      expect(bw.on('2026-09-01'), 72, reason: 'still the latest known');
    });

    test('falls back to the earliest entry for older sets', () async {
      final bw = await lookupOf({'2026-06-01': 68});

      expect(bw.on('2025-01-01'), 68);
    });

    test('reports nothing when no weight was ever logged', () async {
      final bw = await lookupOf({});

      expect(bw.isEmpty, isTrue);
      expect(bw.on('2026-01-01'), isNull);
    });
  });

  group('relativeLoadPercent', () {
    test('adds the added weight on top of body weight', () {
      expect(relativeLoadPercent(70, 20), closeTo(128.57, 0.01));
      expect(relativeLoadPercent(70, 0), 100);
    });

    test('drops below 100% for assisted work', () {
      expect(relativeLoadPercent(70, -14), closeTo(80, 0.01));
    });

    test('has no answer without a usable body weight', () {
      expect(relativeLoadPercent(null, 20), isNull);
      expect(relativeLoadPercent(0, 20), isNull);
    });
  });
}
