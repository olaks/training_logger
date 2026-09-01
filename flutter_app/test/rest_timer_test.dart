import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/providers/app_providers.dart';

/// The countdown runs on real time, so these use short durations and real
/// waits. Feedback (sound, haptics, wakelock) is off — it needs plugins.
void main() {
  late RestTimerNotifier timer;

  setUp(() => timer = RestTimerNotifier(withFeedback: false));
  tearDown(() => timer.dispose());

  test('starts at the chosen duration and counts down in whole seconds',
      () async {
    timer.setDurationAndRestart(3);
    expect(timer.state.active, isTrue);
    expect(timer.state.remaining, 3);
    expect(timer.state.restSecs, 3);

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(timer.state.remaining, 2);
  });

  test('remaining tracks elapsed wall-clock time, not the number of ticks',
      () async {
    timer.setDurationAndRestart(10);
    final startedAt = DateTime.now();

    await Future<void>.delayed(const Duration(milliseconds: 2500));

    // Whatever the timer did in between, the value shown must agree with how
    // much time actually passed — this is what a decrementing counter got
    // wrong once the OS started throttling background timers.
    final elapsed = DateTime.now().difference(startedAt).inMilliseconds / 1000;
    expect(timer.state.remaining, closeTo(10 - elapsed, 1));
  });

  test('holds a completed state, then dismisses itself', () async {
    timer.setDurationAndRestart(1);

    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(timer.state.remaining, 0);
    expect(timer.state.active, isTrue, reason: 'shows "Rest complete" first');

    await Future<void>.delayed(const Duration(seconds: 3));
    expect(timer.state.active, isFalse);
  });

  test('start reuses the last chosen duration', () async {
    timer.setDurationAndRestart(5);
    timer.cancel();
    timer.start();
    expect(timer.state.remaining, 5);
    expect(timer.state.restSecs, 5);
  });

  test('cancel stops the countdown for good', () async {
    timer.setDurationAndRestart(2);
    timer.cancel();
    expect(timer.state.active, isFalse);
    expect(timer.state.remaining, 0);

    await Future<void>.delayed(const Duration(milliseconds: 2400));
    expect(timer.state.active, isFalse,
        reason: 'a cancelled timer must not resurface when it would have ended');
  });

  test('restarting mid-rest replaces the running countdown', () async {
    timer.setDurationAndRestart(2);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    timer.setDurationAndRestart(8);
    expect(timer.state.remaining, 8);

    // The first countdown must not fire and clear the second.
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    expect(timer.state.active, isTrue);
    expect(timer.state.remaining, greaterThan(5));
  });
}
