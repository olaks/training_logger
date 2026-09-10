import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/detail/tabs/track_tab.dart';
import 'package:training_logger/utils/undo_snackbar.dart';

/// The undo snackbar has to fade on its own. A `SnackBar` that carries an
/// action persists by default, and this one is owned by the app-level
/// messenger, so a bar that outstays its duration sits over every screen until
/// the app is killed.
void main() {
  late AppDatabase db;
  late int catId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catId = await db.insertOrGetCategory('Dead Hang');
    await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: catId,
      dateStr: '2026-01-01',
      timestamp: 1,
      weightKg: const Value(20),
      reps: const Value(5),
      timeSecs: const Value(10),
    ));
  });
  tearDown(() => db.close());

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('the undo snackbar times out instead of persisting',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showUndoSnackBar(ScaffoldMessenger.of(context),
                message: 'Set deleted', onUndo: () {}),
            child: const Text('delete'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();
    expect(find.text('Set deleted'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Set deleted'), findsNothing);
  });

  testWidgets('deleting a timed set leaves nothing on screen', (tester) async {
    // The logged-set row sits below the fold of the default 800x600 viewport.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: TrackTab(categoryId: catId, dateStr: '2026-01-01'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // The trailing × on the logged row opens the confirmation.
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Set deleted'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Set deleted'), findsNothing);

    await teardownTree(tester);
  });

  testWidgets('undo still puts the set back', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(
          body: TrackTab(categoryId: catId, dateStr: '2026-01-01'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Set 1'), findsNothing);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text('Set 1'), findsOneWidget);

    await teardownTree(tester);
  });
}
