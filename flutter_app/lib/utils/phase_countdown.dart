import 'dart:async';

/// One phase of a countdown — a hold, a rest, a get-ready.
///
/// Remaining time is always derived from the instant the phase ends rather
/// than by decrementing a counter, because the OS throttles timers whenever
/// the app leaves the foreground and a counter that misses ticks silently runs
/// slow. Ticks come ten times a second so the last-three-seconds cue lands on
/// the right second.
///
/// The countdown owns time only. Sound, haptics and the wakelock stay with the
/// screen that runs it, since each one cues its phases differently and the
/// wakelock belongs to the whole session rather than a single phase.
class PhaseCountdown {
  /// Called on every tick, for redrawing the remaining time.
  final void Function() onChanged;

  /// Called once the phase is up. [overshootMs] is how late the tick was — it
  /// is large when the app was in the background through the end, which is
  /// worth knowing before playing a sound about it.
  final void Function(int overshootMs) onElapsed;

  /// Called once per second over the closing seconds, counting down: 3, 2, 1.
  final void Function(int secsLeft)? onFinalSeconds;

  /// How many closing seconds [onFinalSeconds] covers.
  final int finalSeconds;

  Timer? _timer;
  DateTime? _endsAt;
  DateTime? _pausedAt;
  int _durationSecs = 0;
  int _lastAnnounced = -1;

  PhaseCountdown({
    required this.onChanged,
    required this.onElapsed,
    this.onFinalSeconds,
    this.finalSeconds = 3,
  });

  bool get isRunning => _endsAt != null;
  bool get isPaused  => _pausedAt != null;

  /// Total length of the current phase, for drawing progress.
  int get durationSecs => _durationSecs;

  int get remainingMs {
    final endsAt = _endsAt;
    if (endsAt == null) return 0;
    final from = _pausedAt ?? DateTime.now();
    final ms = endsAt.difference(from).inMilliseconds;
    return ms < 0 ? 0 : ms;
  }

  /// Whole seconds left, rounded up — 0.4s left still reads as 1.
  int get remainingSecs => (remainingMs / 1000).ceil();

  /// Seconds elapsed so far, for logging a phase that was cut short.
  int get elapsedSecs =>
      isRunning ? (_durationSecs - remainingSecs).clamp(0, _durationSecs) : 0;

  /// 1.0 at the start of the phase, 0.0 at its end.
  double get progress =>
      _durationSecs == 0 ? 0 : remainingMs / (_durationSecs * 1000);

  /// Begins (or restarts) the countdown at [seconds].
  void start(int seconds) {
    _durationSecs = seconds;
    _endsAt = DateTime.now().add(Duration(seconds: seconds));
    _pausedAt = null;
    _lastAnnounced = -1;
    _timer ??=
        Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    onChanged();
  }

  void pause() {
    if (!isRunning || isPaused) return;
    _pausedAt = DateTime.now();
    onChanged();
  }

  void resume() {
    final pausedAt = _pausedAt;
    if (!isRunning || pausedAt == null) return;
    // Push the end instant out by however long the pause lasted.
    _endsAt = _endsAt!.add(DateTime.now().difference(pausedAt));
    _pausedAt = null;
    onChanged();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _endsAt = null;
    _pausedAt = null;
  }

  void dispose() => stop();

  void _tick() {
    if (_endsAt == null || isPaused) return;

    final left = _endsAt!.difference(DateTime.now()).inMilliseconds;
    if (left <= 0) {
      onElapsed(-left);
      return;
    }

    final secsLeft = (left / 1000).ceil();
    if (secsLeft != _lastAnnounced && secsLeft <= finalSeconds) {
      _lastAnnounced = secsLeft;
      onFinalSeconds?.call(secsLeft);
    }
    onChanged();
  }
}
