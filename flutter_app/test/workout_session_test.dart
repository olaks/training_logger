import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/plans/workout_session_screen.dart';

/// A workout is trained by stepping through its exercises one at a time, so
/// these check the stepping rather than the logging.
void main() {
  late AppDatabase db;
  late int workoutId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    workoutId = await db.insertWorkout('Push day');
    for (final name in ['Bench', 'Squat', 'Row']) {
      await db.addExerciseToWorkout(workoutId, await db.insertOrGetCategory(name));
    }
  });
  tearDown(() => db.close());

  Future<void> pumpSession(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: WorkoutSessionScreen(workoutId: workoutId, dateStr: '2026-09-03'),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    // Let drift close its stream queries before the tree goes away.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('opens on the first exercise', (tester) async {
    await pumpSession(tester);

    expect(find.text('Push day'), findsOneWidget);
    expect(find.textContaining('Bench  ·  1 of 3'), findsOneWidget);
    await teardownTree(tester);
  });

  testWidgets('NEXT walks forward through the workout', (tester) async {
    await pumpSession(tester);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Squat  ·  2 of 3'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Row  ·  3 of 3'), findsOneWidget);
    await teardownTree(tester);
  });

  testWidgets('PREV walks back, and is dead on the first exercise',
      (tester) async {
    await pumpSession(tester);

    final prev = tester.widget<OutlinedButton>(find.ancestor(
        of: find.text('PREV'), matching: find.byType(OutlinedButton)));
    expect(prev.onPressed, isNull);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PREV'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bench  ·  1 of 3'), findsOneWidget);
    await teardownTree(tester);
  });

  testWidgets('the last exercise offers FINISH instead of NEXT',
      (tester) async {
    await pumpSession(tester);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();

    expect(find.text('NEXT'), findsNothing);
    expect(find.text('FINISH'), findsOneWidget);
    await teardownTree(tester);
  });

  testWidgets('the progress bar jumps straight to an exercise',
      (tester) async {
    await pumpSession(tester);

    // Third segment of the progress bar.
    final segments = find.byType(GestureDetector);
    await tester.tap(segments.at(2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Row  ·  3 of 3'), findsOneWidget);
    await teardownTree(tester);
  });

  testWidgets('says so when the workout is empty', (tester) async {
    final empty = await db.insertWorkout('Nothing here');
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: WorkoutSessionScreen(workoutId: empty, dateStr: '2026-09-03'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('This workout has no exercises yet.'), findsOneWidget);
    await teardownTree(tester);
  });
}
