import '../database/database.dart';

/// Resolves the body weight to use for a given day.
///
/// Weigh-ins are sparse — someone logs their weight now and then, not every
/// session — so the nearest one is carried forward. Sets logged before the
/// first weigh-in fall back to that earliest entry, which keeps years of
/// history on the graph for someone who only started weighing in recently.
class BodyWeightLookup {
  final List<BodyWeight> _entries;

  BodyWeightLookup(Iterable<BodyWeight> entries)
      : _entries = entries.toList()
          ..sort((a, b) => a.dateStr.compareTo(b.dateStr));

  bool get isEmpty => _entries.isEmpty;

  /// Body weight in kg to assume on [dateStr], or null if none was ever
  /// logged.
  double? on(String dateStr) {
    if (_entries.isEmpty) return null;
    BodyWeight? best;
    for (final e in _entries) {
      if (e.dateStr.compareTo(dateStr) > 0) break;
      best = e;
    }
    return (best ?? _entries.first).kg;
  }
}

/// Total load as a percentage of body weight — the finger-strength
/// convention, where 20 kg added at 70 kg body weight reads as 128.6%.
///
/// [addedKg] is the weight hanging off the harness, so it goes negative for
/// band- or pulley-assisted work and lands the result below 100%.
double? relativeLoadPercent(double? bodyWeightKg, double addedKg) {
  if (bodyWeightKg == null || bodyWeightKg <= 0) return null;
  return (bodyWeightKg + addedKg) / bodyWeightKg * 100;
}
