import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/training_load.dart';

const _kMetricKey = 'load_metric';
const _kMethodKey = 'acwr_method';

/// How the athlete has chosen to have training load counted and averaged.
///
/// Both halves change what every figure on the load screen means, so they are
/// remembered rather than reset each launch.
class LoadSettings {
  final LoadMetric metric;
  final AcwrMethod method;

  const LoadSettings({
    this.metric = LoadMetric.rpeWeightedVolume,
    this.method = AcwrMethod.rollingAverage,
  });

  LoadSettings copyWith({LoadMetric? metric, AcwrMethod? method}) =>
      LoadSettings(metric: metric ?? this.metric, method: method ?? this.method);

  /// Reads back what was saved, falling back to the defaults for anything
  /// missing or written by a version that offered different options.
  factory LoadSettings.fromPrefs(SharedPreferences prefs) {
    T? pick<T extends Enum>(List<T> values, String key) {
      final i = prefs.getInt(key);
      return (i != null && i >= 0 && i < values.length) ? values[i] : null;
    }

    const fallback = LoadSettings();
    return LoadSettings(
      metric: pick(LoadMetric.values, _kMetricKey) ?? fallback.metric,
      method: pick(AcwrMethod.values, _kMethodKey) ?? fallback.method,
    );
  }
}

class LoadSettingsNotifier extends StateNotifier<LoadSettings> {
  /// Null in tests and anywhere the app has not been started through `main` —
  /// the settings still work, they just do not outlive the session.
  final SharedPreferences? _prefs;

  LoadSettingsNotifier(super.initial, this._prefs);

  void setMetric(LoadMetric metric) {
    state = state.copyWith(metric: metric);
    _prefs?.setInt(_kMetricKey, metric.index);
  }

  void setMethod(AcwrMethod method) {
    state = state.copyWith(method: method);
    _prefs?.setInt(_kMethodKey, method.index);
  }
}

// Overridden in main() with the persisted values.
final loadSettingsProvider =
    StateNotifierProvider<LoadSettingsNotifier, LoadSettings>(
        (ref) => LoadSettingsNotifier(const LoadSettings(), null));
