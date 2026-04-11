String dateStrFrom(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';

DateTime dateFromStr(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String formatWeight(double w) =>
    w == w.truncateToDouble() ? w.toInt().toString() : w.toStringAsFixed(1);

String formatTime(int secs) {
  final m = secs ~/ 60;
  final s = secs % 60;
  return m > 0 ? '${m}m ${s}s' : '${s}s';
}

String formatSet({double? weightKg, int? reps, int? timeSecs}) {
  final parts = <String>[
    if (weightKg != null && weightKg != 0) '${formatWeight(weightKg)} kg',
    if (reps != null && reps > 0) '$reps reps',
    if (timeSecs != null && timeSecs > 0) formatTime(timeSecs),
  ];
  return parts.isEmpty ? '—' : parts.join('  ·  ');
}
