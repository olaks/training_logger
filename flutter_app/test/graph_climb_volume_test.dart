import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/detail/tabs/graph_tab.dart';

/// A climbing session has two numbers worth seeing — how hard it was and how
/// much of it there was — so the grade chart carries the climb count with it.
void main() {
  late AppDatabase db;
  late int catId;

  /// Logs [grades] on [date], one set each.
  Future<void> logSession(String date, List<String> grades) async {
    for (var i = 0; i < grades.length; i++) {
      await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr: date,
        timestamp: i,
        grade: Value(grades[i]),
      ));
    }
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catId = await db.insertOrGetCategory('Bouldering');
    await db.setExerciseType(catId, 1);
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

  testWidgets('shows climb volume alongside the grade, and can hide it',
      (tester) async {
    await tester.runAsync(() async {
      await logSession('2026-01-02', ['6A', '6B', '6C']);
      await logSession('2026-01-05', ['7A', '6C+']);
    });
    await pumpGraph(tester);

    expect(find.text('Best Grade'), findsOneWidget);
    expect(find.textContaining('peak 3'), findsOneWidget,
        reason: 'the shaded area has no axis, so its scale is written out');

    await tester.tap(find.text('Climbs'));
    await tester.pumpAndSettle();
    expect(find.textContaining('peak 3'), findsNothing);

    await teardownTree(tester);
  });

  testWidgets('counts a climb whose grade is off the detected scale',
      (tester) async {
    await tester.runAsync(() async {
      // V-grades win the scale detection, so the Font entry is a climb the
      // grade line cannot plot — it still happened.
      await logSession('2026-01-02', ['V4', '7A']);
      await logSession('2026-01-05', ['V5']);
    });
    await pumpGraph(tester);

    expect(find.textContaining('peak 2'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('offers no climb overlay on a standard exercise', (tester) async {
    await tester.runAsync(() async {
      await db.setExerciseType(catId, 0);
      for (final date in ['2026-01-02', '2026-01-05']) {
        await db.insertSet(WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: date,
          timestamp: 1,
          weightKg: const Value(20),
          reps: const Value(5),
        ));
      }
    });
    await pumpGraph(tester);

    expect(find.text('Climbs'), findsNothing);

    await teardownTree(tester);
  });
}
