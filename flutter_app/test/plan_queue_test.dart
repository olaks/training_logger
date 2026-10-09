import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_logger/app.dart';
import 'package:training_logger/database/database.dart';
import 'package:training_logger/providers/app_providers.dart';
import 'package:training_logger/providers/backup_provider.dart';
import 'package:training_logger/providers/load_settings_provider.dart';
import 'package:training_logger/providers/theme_provider.dart';
import 'package:training_logger/utils/format_utils.dart';

/// A periodized plan is run from the day view: it lists the sessions still
/// due this week, and finishing one there moves the week on.
void main() {
  late AppDatabase db;
  late SharedPreferences prefs;
  late int plan;
  late int capacity;
  late int strengthA;
  late int board;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    strengthA = await db.insertWorkout('Strength A');
    await db.addExerciseToWorkout(
        strengthA, await db.insertOrGetCategory('Bench'));
    board = await db.insertWorkout('Board');
    await db.addExerciseToWorkout(
        board, await db.insertOrGetCategory('Board climbing'));

    plan = await db.insertPlan('Season');
    await db.setCycleDays(plan, 1);
    capacity = await db.insertPhase(plan, 'Capacity',
        lengthPasses: 10, deloadEvery: 4);
    await db.addSessionToPhase(capacity, strengthA, day: 1);
    await db.addSessionToPhase(capacity, board, day: 1);
  });
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        themeIndexProvider.overrideWith(() => ThemeNotifier(0, prefs)),
        loadSettingsProvider.overrideWith(
            () => LoadSettingsNotifier(LoadSettings.fromPrefs(prefs), prefs)),
      ],
      child: const TrainingLoggerApp(),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('the day view lists the sessions due this week', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Capacity · week 1/10'), findsOneWidget);
    expect(find.text('2 workouts left this week'), findsOneWidget);
    expect(find.text('STRENGTH A'), findsOneWidget);
    expect(find.text('BOARD'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('finishing a session started from the day view ticks it off',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('START').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FINISH'));
    await tester.pumpAndSettle();

    expect(find.text('1 workout left this week'), findsOneWidget);
    expect(find.text('Strength A done'), findsOneWidget,
        reason: 'the snackbar confirms it, with an undo');

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text('2 workouts left this week'), findsOneWidget);

    await teardownTree(tester);
  });

  testWidgets('a finished phase asks before moving on', (tester) async {
    await db.updatePhase(capacity,
        name: 'Capacity', lengthPasses: 1, deloadEvery: null);
    await db.insertPhase(plan, 'Basic strength', lengthPasses: 8);
    final today = dateStrFrom(DateTime.now());
    await db.finishSession(strengthA, today);
    await db.finishSession(board, today);

    await pumpApp(tester);
    expect(find.textContaining('Capacity is done'), findsOneWidget);

    await tester.tap(find.text('Start Basic strength'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Basic strength · week 1/8'),
        findsOneWidget);

    await teardownTree(tester);
  });
}
