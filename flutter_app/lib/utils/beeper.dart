import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Short synthesized beeps shared by the countdown timers.
///
/// One [AudioPlayer] per tone, with the source loaded once at construction so
/// each play is just seek+resume — no temp-file writes, no native re-init.
class Beeper {
  final AudioPlayer _high;
  final AudioPlayer _low;
  final AudioPlayer _tick;
  final AudioPlayer _done;

  Beeper()
      : _high = _makePlayer(generateTone(880, 0.15)),
        _low  = _makePlayer(generateTone(440, 0.15)),
        _tick = _makePlayer(generateTone(660, 0.08)),
        _done = _makePlayer(generateTone(1760, 0.4));

  /// A work phase is starting.
  void high() => _play(_high);

  /// A work phase has ended and a rest follows.
  void low() => _play(_low);

  /// One of the final 3-2-1 counts.
  void tick() => _play(_tick);

  /// The whole session is finished.
  void done() => _play(_done);

  void dispose() {
    _high.dispose();
    _low.dispose();
    _tick.dispose();
    _done.dispose();
  }

  static void _play(AudioPlayer p) {
    p.seek(Duration.zero).then((_) => p.resume()).catchError((_) {});
  }

  static AudioPlayer _makePlayer(Uint8List bytes) {
    final p = AudioPlayer();
    // Fire-and-forget configuration. Stay in the default mediaPlayer mode:
    // Android's lowLatency (SoundPool) backend rejects byte sources
    // ("Bytes sources are not supported on LOW_LATENCY mode yet"), which left
    // the hangboard timer completely silent. mediaPlayer mode loads the source
    // once and supports seek-to-zero replays.
    p.setReleaseMode(ReleaseMode.stop);
    p.setSourceBytes(bytes);
    return p;
  }
}

/// Generates a mono 16-bit 44100 Hz WAV containing a sine wave.
Uint8List generateTone(double freq, double durSecs) {
  const sr = 44100;
  final n = (sr * durSecs).toInt();
  final dataSize = n * 2;
  final buf = ByteData(44 + dataSize);

  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      buf.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  buf.setUint32(4, 36 + dataSize, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  buf.setUint32(16, 16, Endian.little);
  buf.setUint16(20, 1, Endian.little);
  buf.setUint16(22, 1, Endian.little);
  buf.setUint32(24, sr, Endian.little);
  buf.setUint32(28, sr * 2, Endian.little);
  buf.setUint16(32, 2, Endian.little);
  buf.setUint16(34, 16, Endian.little);
  str(36, 'data');
  buf.setUint32(40, dataSize, Endian.little);

  final fade = min(n ~/ 4, sr ~/ 100);
  for (var i = 0; i < n; i++) {
    var env = 1.0;
    if (i < fade) env = i / fade;
    if (i > n - fade) env = (n - i) / fade;
    final s = (sin(2 * pi * freq * i / sr) * 32767 * 0.8 * env).toInt();
    buf.setInt16(44 + i * 2, s.clamp(-32768, 32767), Endian.little);
  }
  return buf.buffer.asUint8List();
}
