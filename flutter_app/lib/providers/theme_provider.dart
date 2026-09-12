import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'theme_index';

class ThemeNotifier extends Notifier<int> {
  final int _initial;
  final SharedPreferences _prefs;
  ThemeNotifier(this._initial, this._prefs);

  @override
  int build() => _initial;

  void setTheme(int index) {
    state = index;
    _prefs.setInt(_kThemeKey, index);
  }
}

// Overridden in main() with the persisted value.
final themeIndexProvider = NotifierProvider<ThemeNotifier, int>(
    () => throw UnimplementedError('themeIndexProvider must be overridden'));
