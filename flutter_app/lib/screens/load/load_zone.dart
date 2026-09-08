import 'package:flutter/material.dart';
import '../../utils/training_load.dart';

/// How each ACWR zone reads on screen.
///
/// The colours are fixed rather than drawn from the accent theme: the whole
/// point of the bands is that "green" and "red" mean the same thing every
/// time you glance at them, whichever accent is selected.
extension LoadZoneStyle on LoadZone {
  Color get color => switch (this) {
        LoadZone.unknown => const Color(0xFF757575),
        LoadZone.detraining => const Color(0xFF42A5F5),
        LoadZone.optimal => const Color(0xFF43A047),
        LoadZone.caution => const Color(0xFFFFA726),
        LoadZone.spike => const Color(0xFFE53935),
      };

  String get label => switch (this) {
        LoadZone.unknown => 'No baseline yet',
        LoadZone.detraining => 'Undertraining',
        LoadZone.optimal => 'Sweet spot',
        LoadZone.caution => 'Ramping up',
        LoadZone.spike => 'Spike',
      };

  /// One line on what the zone is actually telling you to do.
  String get advice => switch (this) {
        LoadZone.unknown =>
          'Not enough logged history yet to compare this week against.',
        LoadZone.detraining =>
          'This week sits well below your recent baseline — fine while '
              'recovering or tapering, but the baseline decays if it lasts.',
        LoadZone.optimal =>
          'This week is in line with what you have been building towards.',
        LoadZone.caution =>
          'You are ramping faster than your baseline supports. Worth holding '
              'here rather than adding more.',
        LoadZone.spike =>
          'A sharp jump above your baseline — the pattern most associated '
              'with overuse injury. Consider easing off.',
      };
}

/// Ratio at the top of the gauge. Ratios run past this, so the marker clamps;
/// stretching the axis to fit an outlier would squash the bands that matter.
const kGaugeMax = 2.0;

/// A horizontal 0–[kGaugeMax] gauge with the ACWR bands drawn in and a marker
/// at the current ratio.
class ZoneGauge extends StatelessWidget {
  final double? ratio;
  final double height;
  const ZoneGauge({super.key, required this.ratio, this.height = 8});

  @override
  Widget build(BuildContext context) {
    const bands = <(double, double, LoadZone)>[
      (0.0, 0.8, LoadZone.detraining),
      (0.8, 1.3, LoadZone.optimal),
      (1.3, 1.5, LoadZone.caution),
      (1.5, kGaugeMax, LoadZone.spike),
    ];

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      double x(double r) => (r / kGaugeMax).clamp(0.0, 1.0) * w;
      final marker = ratio == null ? null : x(ratio!);

      return SizedBox(
        height: height + 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: Row(
                  children: [
                    for (final (from, to, zone) in bands)
                      SizedBox(
                        width: x(to) - x(from),
                        height: height,
                        // The band you are in is stated plainly; the rest are
                        // context, so they stay faint enough to read past.
                        child: ColoredBox(
                          color: zone.color.withValues(
                              alpha: zone == zoneFor(ratio) ? 0.85 : 0.18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (marker != null)
              Positioned(
                left: (marker - 2).clamp(0.0, w - 4),
                top: 0,
                child: Container(
                  width: 4,
                  height: height + 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 3),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
