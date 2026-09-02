import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/utils/phase_countdown.dart';

void main() {
  late PhaseCountdown countdown;
  late List<int> announced;
  late int elapsedCalls;

  setUp(() {
    announced = [];
    elapsedCalls = 0;
    countdown = PhaseCountdown(
      onChanged: () {},
      onElapsed: (_) => elapsedCalls++,
      onFinalSeconds: announced.add,
    );
  });
  tearDown(() => countdown.dispose());

  test('reports remaining time from the end instant', () async {
    countdown.start(3);
    expect(countdown.remainingSecs, 3);
    expect(countdown.isRunning, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(countdown.remainingSecs, 2);
    expect(countdown.elapsedSecs, 1);
    expect(countdown.progress, lessThan(0.7));
  });

  test('counts the closing seconds down exactly once each', () async {
    countdown.start(2);
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    expect(announced, [2, 1]);
    expect(elapsedCalls, greaterThanOrEqualTo(1));
  });

  test('a pause freezes the clock and resuming gives the time back', () async {
    countdown.start(5);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    countdown.pause();
    final frozen = countdown.remainingMs;

    await Future<void>.delayed(const Duration(milliseconds: 700));
    expect(countdown.remainingMs, frozen, reason: 'paused time does not run');
    expect(elapsedCalls, 0);

    countdown.resume();
    expect(countdown.remainingMs, closeTo(frozen, 60));
  });

  test('stopping ends it for good', () async {
    countdown.start(1);
    countdown.stop();
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(elapsedCalls, 0);
    expect(countdown.isRunning, isFalse);
  });

  test('restarting replaces the phase in flight', () async {
    countdown.start(1);
    countdown.start(5);
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(elapsedCalls, 0);
    expect(countdown.remainingSecs, greaterThan(3));
  });
}
