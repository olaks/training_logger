import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/screens/detail/tabs/track_tab.dart';
import 'package:training_logger/utils/format_utils.dart';

/// The Track tab says what effort the plan asks for, and starts the RPE input
/// there so logging against the target is one tap.
void main() {
  late AppDatabase db;
  late int bench;
  late int workout;

  // The plan's targets are today's; a past day shows what applied then.
  final today = dateStrFrom(DateTime.now());

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    bench = await db.insertOrGetCategory('Bench');
    workout = await db.insertWorkout('Push');
    await db.addExerciseToWorkout(workout, bench);
    final we = (await db.watchExercisesForWorkout(workout).first).single.$1;
    await db.updateWorkoutTarget(we, 4, 6);
    await db.updateWorkoutTargetRpe(we, 8);
  });
  tearDown(() => db.close());

  Future<void> pumpTrack(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Scaffold(body: TrackTab(categoryId: bench, dateStr: today)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('the target shows its RPE, and the RPE input starts there',
      (tester) async {
    final week = await db.insertPlan('Week');
    await db.assignWorkoutToPlan(week, workout,
        weekday: DateTime.now().weekday);
    // An earlier set at a different effort: the target still wins.
    await db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: bench,
      dateStr: '2026-02-23',
      timestamp: 1,
      weightKg: const Value(60),
      reps: const Value(6),
      rpe: const Value(6),
    ));

    await pumpTrack(tester);

    expect(find.textContaining('4 × 6 reps @ RPE 8'), findsOneWidget);
    expect(find.text('Very Hard'), findsOneWidget,
        reason: 'the RPE input is prefilled with 8');

    await teardownTree(tester);
  });

  testWidgets('a deload pass shows RPE 5 and says so', (tester) async {
    final plan = await db.insertPlan('Season');
    final phase = await db.insertPhase(plan, 'Capacity', lengthPasses: 10);
    await db.addSessionToPhase(phase, workout);
    await db.deloadNow(today);

    await pumpTrack(tester);

    expect(find.textContaining('@ RPE 5'), findsOneWidget);
    expect(find.textContaining('Deload'), findsOneWidget);
    expect(find.text('Moderate'), findsOneWidget,
        reason: 'the RPE input is prefilled with 5');

    await teardownTree(tester);
  });
}
