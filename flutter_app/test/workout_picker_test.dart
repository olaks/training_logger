import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/plans/workout_detail_screen.dart';

/// A new workout opens straight onto the exercise picker, since adding
/// exercises is the only thing to do with it. One that has exercises opens
/// onto them.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Opens the workout the way the Plans screen does: from a list that has
  /// already loaded every workout, so only its exercises are still to come.
  Future<void> pumpDetail(WidgetTester tester, int workoutId) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(workoutId: workoutId))),
              child: Text(
                  '${ref.watch(allWorkoutsProvider).value?.length} workouts'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('1 workouts'), findsOneWidget);
    await tester.tap(find.text('1 workouts'));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('a workout with exercises opens without the picker',
      (tester) async {
    final id = await db.insertWorkout('Push day');
    await db.addExerciseToWorkout(id, await db.insertOrGetCategory('Bench'));
    await pumpDetail(tester, id);

    expect(find.text('Bench'), findsOneWidget);
    expect(find.text('Search exercises'), findsNothing,
        reason: 'the picker opened while the exercises were still loading');

    await teardownTree(tester);
  });

  testWidgets('an empty workout opens onto the picker', (tester) async {
    final id = await db.insertWorkout('New');
    await pumpDetail(tester, id);

    expect(find.text('Search exercises'), findsOneWidget);

    await teardownTree(tester);
  });
}
