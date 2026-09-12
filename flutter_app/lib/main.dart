import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/backup_provider.dart';
import 'providers/load_settings_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedIndex = prefs.getInt('theme_index') ?? 0;

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        themeIndexProvider.overrideWith(
          () => ThemeNotifier(savedIndex, prefs),
        ),
        loadSettingsProvider.overrideWith(
          () => LoadSettingsNotifier(LoadSettings.fromPrefs(prefs), prefs),
        ),
      ],
      child: const TrainingLoggerApp(),
    ),
  );
}
