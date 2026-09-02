import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/plans/workout_detail_screen.dart';

/// A workout can be trained without being scheduled in a plan first.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpDetail(WidgetTester tester, int workoutId) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(home: WorkoutDetailScreen(workoutId: workoutId)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  FilledButton startButton(WidgetTester tester) => tester.widget<FilledButton>(
      find.ancestor(of: find.text('START'), matching: find.byType(FilledButton)));

  testWidgets('a workout with exercises can be started from its own screen',
      (tester) async {
    final id = await db.insertWorkout('Push day');
    await db.addExerciseToWorkout(id, await db.insertOrGetCategory('Bench'));
    await pumpDetail(tester, id);

    expect(startButton(tester).onPressed, isNotNull);
    await teardownTree(tester);
  });

  testWidgets('an empty workout has nothing to start', (tester) async {
    final id = await db.insertWorkout('Empty');
    await pumpDetail(tester, id);

    expect(startButton(tester).onPressed, isNull);
    await teardownTree(tester);
  });
}
