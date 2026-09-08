import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/load/load_method_screen.dart';
import 'package:training_logger/screens/load/load_summary_card.dart';
import 'package:training_logger/screens/load/training_load_screen.dart';
import 'package:training_logger/providers/load_settings_provider.dart';
import 'package:training_logger/utils/format_utils.dart';
import 'package:training_logger/utils/training_load.dart';

/// The load series is anchored on `DateTime.now()`, so the fixture is written
/// relative to today rather than to fixed dates that would age out.
void main() {
  late AppDatabase db;

  String daysAgo(int n) {
    final now = DateTime.now();
    return dateStrFrom(DateTime(now.year, now.month, now.day - n));
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final catId = await db.insertOrGetCategory('Bench Press');

    // Four steady weeks, then a week at triple the volume: an acute:chronic
    // ratio of exactly 2.0, deep in the spike band.
    for (var d = 35; d >= 0; d--) {
      await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr: daysAgo(d),
        timestamp: 1,
        weightKg: const Value(100),
        reps: Value(d >= 7 ? 5 : 15),
      ));
    }
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(home: Scaffold(body: child)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('the home card reports the current ratio and zone',
      (tester) async {
    await pump(tester, const LoadSummaryCard());

    expect(find.text('TRAINING LOAD'), findsOneWidget);
    expect(find.text('2.00'), findsOneWidget);
    expect(find.text('Spike'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('the card stays out of the way when nothing is logged',
      (tester) async {
    final empty = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(empty.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(empty)],
      child: const MaterialApp(home: Scaffold(body: LoadSummaryCard())),
    ));
    await tester.pumpAndSettle();

    expect(find.text('TRAINING LOAD'), findsNothing);

    await teardownTree(tester);
  });

  testWidgets('the screen explains the zone and how load was counted',
      (tester) async {
    await pump(tester, const TrainingLoadScreen());

    expect(find.text('2.00'), findsOneWidget);
    expect(find.text('Spike'), findsOneWidget);
    expect(find.textContaining('sharp jump above your baseline'), findsOneWidget);

    // Past the charts sits the way into the full explanation, carrying the
    // caveat that this log has no RPE in it at all.
    await tester.scrollUntilVisible(
      find.text('How this is calculated'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('No RPE logged yet'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('switching to EWMA recomputes the ratio', (tester) async {
    await pump(tester, const TrainingLoadScreen());
    expect(find.text('2.00'), findsOneWidget);

    await tester.tap(find.text('EWMA'));
    await tester.pumpAndSettle();

    // EWMA weights the spike week far more heavily than a flat 28-day window
    // does, so the same training reads as a bigger jump.
    expect(find.text('2.00'), findsNothing);
    expect(find.text('Spike'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('switching the load metric changes what is counted',
      (tester) async {
    await pump(tester, const TrainingLoadScreen());

    // The fixture carries no RPE, so volume and RPE-weighted volume agree;
    // session RPE throws the weight away and lands somewhere else entirely.
    expect(find.text('2.00'), findsOneWidget);
    expect(find.textContaining('kg·reps'), findsWidgets);

    await tester.tap(find.text('Session RPE'));
    await tester.pumpAndSettle();

    expect(find.textContaining('RPE·reps'), findsWidgets);
    // Reps tripled in the spike week while the weight stayed put, so a
    // rep-based metric still reads the ramp.
    expect(find.text('Spike'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('the explainer offers the same choices, and they stick',
      (tester) async {
    late WidgetRef captured;
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Consumer(builder: (c, ref, _) {
          captured = ref;
          return const LoadMethodScreen();
        }),
      ),
    ));
    await tester.pumpAndSettle();

    // The explanation comes first and the pickers sit inside it, so each is
    // scrolled to rather than assumed on screen.
    final list = find.byType(Scrollable).first;
    expect(find.textContaining('sweet spot'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Volume'), 200, scrollable: list);
    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();
    expect(captured.read(loadSettingsProvider).metric, LoadMetric.volume);

    await tester.scrollUntilVisible(find.text('Session RPE'), 200,
        scrollable: list);
    await tester.scrollUntilVisible(find.text('EWMA'), 200, scrollable: list);
    expect(find.text('Rolling average'), findsOneWidget);
    await tester.tap(find.text('EWMA'));
    await tester.pumpAndSettle();
    expect(captured.read(loadSettingsProvider).method, AcwrMethod.ewma);

    await teardownTree(tester);
  });

  testWidgets('an empty log invites you to start rather than showing 0.00',
      (tester) async {
    final empty = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(empty.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(empty)],
      child: const MaterialApp(home: TrainingLoadScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('will build up here'), findsOneWidget);

    await teardownTree(tester);
  });
}
