import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/detail/tabs/graph_tab.dart';

/// The % Body Weight metric only makes sense once weigh-ins exist, so this
/// checks the graph offers it exactly then.
void main() {
  late AppDatabase db;
  late int catId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catId = await db.insertOrGetCategory('Dead Hang');
    for (final (date, kg) in [('2026-01-01', 20.0), ('2026-01-08', 22.5)]) {
      await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr: date,
        timestamp: 1,
        weightKg: Value(kg),
        timeSecs: const Value(10),
      ));
    }
  });
  tearDown(() => db.close());

  Future<void> pumpGraph(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(home: Scaffold(body: GraphTab(categoryId: catId))),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    // Disposing the scope leaves drift a zero-duration timer to close its
    // stream queries; advancing the clock runs it before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('offers % body weight once a weigh-in exists', (tester) async {
    await tester.runAsync(() => db.saveBodyWeight('2026-01-01', 70));
    await pumpGraph(tester);

    final chip = tester.widget<ChoiceChip>(find.ancestor(
        of: find.text('% Body Weight'), matching: find.byType(ChoiceChip)));
    expect(chip.onSelected, isNotNull, reason: 'selectable');

    await tester.tap(find.text('% Body Weight'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('(body weight + added) ÷ body weight'),
        findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('disables it while no body weight is logged', (tester) async {
    await pumpGraph(tester);

    final chip = tester.widget<ChoiceChip>(find.ancestor(
        of: find.text('% Body Weight'), matching: find.byType(ChoiceChip)));
    expect(chip.onSelected, isNull);
    expect(find.text('Body weight'), findsNothing,
        reason: 'no overlay to offer either');

    await teardownTree(tester);
  });

  testWidgets('offers the body weight overlay on the kg metrics',
      (tester) async {
    await tester.runAsync(() => db.saveBodyWeight('2026-01-01', 70));
    await pumpGraph(tester);

    expect(find.text('Body weight'), findsOneWidget);
    await tester.tap(find.text('% Body Weight'));
    await tester.pumpAndSettle();
    expect(find.text('Body weight'), findsNothing,
        reason: 'kg does not share an axis with a percentage');

    await teardownTree(tester);
  });
}
