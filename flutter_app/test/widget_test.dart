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

/// Starting the app is the one path nothing else covers: the provider
/// overrides `main()` installs are only wrong at runtime.
void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({'theme_index': 2});
    prefs = await SharedPreferences.getInstance();
  });
  tearDown(() => db.close());

  testWidgets('the app starts on the day view with its bottom nav',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        prefsProvider.overrideWithValue(prefs),
        themeIndexProvider.overrideWith(() => ThemeNotifier(2, prefs)),
        loadSettingsProvider.overrideWith(
            () => LoadSettingsNotifier(LoadSettings.fromPrefs(prefs), prefs)),
      ],
      child: const TrainingLoggerApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    // The day the app opens on is today, which the nav bar shows as the
    // selected destination.
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
