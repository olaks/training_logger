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

/// A delete's undo is offered by a snackbar that outlives the screen or
/// dialog the delete came from, so tapping UNDO must not reach back through
/// that widget.
void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
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

  Future<void> tapUndo(WidgetTester tester) async {
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
  }

  testWidgets('a plan deleted from its own screen comes back on undo',
      (tester) async {
    await db.insertPlan('Week');
    await pumpApp(tester);

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => db.watchAllPlans().first), isEmpty);

    await tapUndo(tester);
    expect((await tester.runAsync(() => db.watchAllPlans().first))!.single.name, 'Week');

    await teardownTree(tester);
  });

  testWidgets('a workout deleted from its own screen comes back on undo',
      (tester) async {
    final w = await db.insertWorkout('Push');
    await db.addExerciseToWorkout(w, await db.insertOrGetCategory('Bench'));
    await pumpApp(tester);

    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();
    // The plans list stays in the tree under the pushed screen.
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => db.watchAllWorkouts().first), isEmpty);

    await tapUndo(tester);
    expect((await tester.runAsync(() => db.watchAllWorkouts().first))!.single.name, 'Push');

    await teardownTree(tester);
  });

  testWidgets('an exercise deleted from the list comes back on undo',
      (tester) async {
    await db.insertOrGetCategory('Aaa Lift');
    await pumpApp(tester);

    await tester.tap(find.text('Exercises').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aaa');
    await tester.pumpAndSettle();
    final tile = find.ancestor(
        of: find.text('Aaa Lift'), matching: find.byType(ListTile));
    await tester.tap(
        find.descendant(of: tile, matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    Future<Iterable<String>> names() async =>
        (await tester.runAsync(() => db.watchAllCategories().first))!
            .map((c) => c.name);
    expect(await names(), isNot(contains('Aaa Lift')));

    await tapUndo(tester);
    expect(await names(), contains('Aaa Lift'));

    await teardownTree(tester);
  });
}
