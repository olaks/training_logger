import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/providers/app_providers.dart';

/// The home screen's day. A phone left open overnight used to keep showing
/// the day it was put down on, which is how a set gets logged against
/// yesterday.
void main() {
  late DateTime now;
  late ProviderContainer container;

  SelectedDateNotifier notifier() =>
      container.read(selectedDateProvider.notifier);

  setUp(() {
    now = DateTime(2026, 9, 12, 22, 30);
    container = ProviderContainer(overrides: [
      selectedDateProvider
          .overrideWith(() => SelectedDateNotifier(now: () => now)),
    ]);
  });
  tearDown(() => container.dispose());

  test('starts on today, at midnight', () {
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 12));
  });

  test('a day shown as today follows the clock past midnight', () {
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 12));

    now = DateTime(2026, 9, 13, 6, 15);
    notifier().rollOverIfStale();

    expect(container.read(selectedDateProvider), DateTime(2026, 9, 13));
  });

  test('a day opened in the past stays put', () {
    notifier().select(DateTime(2026, 9, 5));

    now = DateTime(2026, 9, 13, 6, 15);
    notifier().rollOverIfStale();

    expect(container.read(selectedDateProvider), DateTime(2026, 9, 5));
  });

  test('stepping a day at a time does not resurface today', () {
    notifier().shiftDays(-1);
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 11));

    now = DateTime(2026, 9, 13, 6, 15);
    notifier().rollOverIfStale();
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 11));

    notifier().shiftDays(1);
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 12));
  });

  test('nothing moves while the day has not turned', () {
    now = DateTime(2026, 9, 12, 23, 59);
    notifier().rollOverIfStale();
    expect(container.read(selectedDateProvider), DateTime(2026, 9, 12));
  });
}
