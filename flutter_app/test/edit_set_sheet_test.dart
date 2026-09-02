import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/detail/edit_set_sheet.dart';
import 'package:training_logger/screens/detail/widgets/set_inputs.dart';
import 'package:training_logger/utils/grades.dart';

/// Widget tests run in fake time, where a real database never answers, so
/// every call into drift goes through [WidgetTester.runAsync].
void main() {
  late AppDatabase db;
  late int catId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catId = await db.insertOrGetCategory('Dead Hang');
  });
  tearDown(() => db.close());

  Future<T> real<T>(WidgetTester tester, Future<T> Function() body) async =>
      (await tester.runAsync(body)) as T;

  Future<WorkoutSet> loggedSet(WidgetTester tester) =>
      real(tester, () async =>
          (await db.watchSetsForCategory(catId).first).single);

  Future<void> logSet(WidgetTester tester, WorkoutSetsCompanion set) =>
      real(tester, () => db.insertSet(set));

  /// Opens the sheet on the single logged set, as the Track and History tabs
  /// do.
  Future<void> openSheet(WidgetTester tester) async {
    final set = await loggedSet(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEditSetSheet(context, set,
                  gradeScale: fontGrades),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder stepper(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(StepperRow));

  Future<void> step(WidgetTester tester, String label, String button) async {
    await tester.tap(
        find.descendant(of: stepper(label), matching: find.text(button)));
    await tester.pump();
  }

  /// Saving writes to the database, so the tap needs real time to land.
  Future<void> save(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(find.text('SAVE'));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('saves a corrected set back to the same row', (tester) async {
    await logSet(
        tester,
        WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: '2026-01-01',
          timestamp: 1,
          weightKg: const Value(20),
          reps: const Value(5),
        ));
    await openSheet(tester);

    await step(tester, 'WEIGHT (KG)', '+');
    await step(tester, 'REPS', '−');
    await save(tester);

    final s = await loggedSet(tester);
    expect(s.weightKg, 21);
    expect(s.reps, 4);
    expect(s.dateStr, '2026-01-01');
  });

  testWidgets('opens showing what was logged', (tester) async {
    await logSet(
        tester,
        WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: '2026-01-01',
          timestamp: 1,
          weightKg: const Value(12.5),
          timeSecs: const Value(10),
          rpe: const Value(8),
        ));
    await openSheet(tester);

    expect(find.text('12.5'), findsOneWidget);
    expect(find.text('10s'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Very Hard'), findsOneWidget);
  });

  testWidgets('cancelling changes nothing', (tester) async {
    await logSet(
        tester,
        WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: '2026-01-01',
          timestamp: 1,
          reps: const Value(5),
        ));
    await openSheet(tester);

    await step(tester, 'REPS', '+');
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect((await loggedSet(tester)).reps, 5);
  });

  testWidgets('refuses to save a set with nothing left in it', (tester) async {
    await logSet(
        tester,
        WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: '2026-01-01',
          timestamp: 1,
          reps: const Value(1),
        ));
    await openSheet(tester);

    await step(tester, 'REPS', '−');

    final save = tester.widget<FilledButton>(find.ancestor(
        of: find.text('SAVE'), matching: find.byType(FilledButton)));
    expect(save.onPressed, isNull);
  });

  testWidgets('steps a climbing set through the detected grade scale',
      (tester) async {
    await logSet(
        tester,
        WorkoutSetsCompanion.insert(
          categoryId: catId,
          dateStr: '2026-01-01',
          timestamp: 1,
          grade: const Value('6C'),
          wallAngle: const Value(20),
        ));
    await openSheet(tester);

    expect(find.text('6C'), findsOneWidget);
    expect(find.text('20°'), findsOneWidget);
    // The grade stepper sits above the wall-angle one.
    await tester.tap(find.widgetWithText(StepBtn, '+').first);
    await tester.pump();
    await save(tester);

    expect((await loggedSet(tester)).grade, '6C+');
  });
}
