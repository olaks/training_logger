import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_index';

class ThemeNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  ThemeNotifier(super.initial, this._prefs);

  void setTheme(int index) {
    state = index;
    _prefs.setInt(_kThemeKey, index);
  }
}

// Overridden in main() with the persisted value.
final themeIndexProvider =
    StateNotifierProvider<ThemeNotifier, int>((ref) => throw UnimplementedError());
