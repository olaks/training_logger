import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';

// ── Timer phases ─────────────────────────────────────────────────────────────

enum _Phase { idle, getReady, work, rest, switchRest, setRest, done }

// ── Screen ───────────────────────────────────────────────────────────────────

class HangboardScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  const HangboardScreen({super.key, this.categoryId});

  @override
  ConsumerState<HangboardScreen> createState() => _HangboardScreenState();
}

class _HangboardScreenState extends ConsumerState<HangboardScreen> {
  // ── Config ───────────────────────────────────────────────────────────────
  int _sets = 5;
  int _reps = 5;
  int _workSecs = 3;
  int _restSecs = 8;
  int _setRestSecs = 180;
  bool _rlMode = false;
  int _switchRestSecs = 10;
  final _weightCtrl = TextEditingController(text: '0');

  // ── Timer state ──────────────────────────────────────────────────────────
  _Phase _phase = _Phase.idle;
  int _secondsLeft = 0;
  int _phaseDuration = 0; // total seconds for current phase (for progress)
  int _currentSet = 1;
  int _currentRep = 1;
  bool _isLeftHand = false;
  bool _paused = false;
  Timer? _timer;

  // ── Exercise to log against (standalone mode) ────────────────────────────
  int? _selectedCategoryId;

  // ── Weight per set ───────────────────────────────────────────────────────
  final Map<int, double> _setWeights = {};

  // ── Audio ────────────────────────────────────────────────────────────────
  final _player = AudioPlayer();
  late final Uint8List _highBeep = _generateTone(880, 0.15);
  late final Uint8List _lowBeep = _generateTone(440, 0.15);
  late final Uint8List _tickBeep = _generateTone(660, 0.08);
  late final Uint8List _doneBeep = _generateTone(1760, 0.4);

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ── Audio helpers ────────────────────────────────────────────────────────

  void _playBeep(Uint8List wav) =>
      _player.play(BytesSource(wav), volume: 1.0);

  /// Generates a mono 16-bit 44100 Hz WAV containing a sine wave.
  static Uint8List _generateTone(double freq, double durSecs) {
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
      final s =
          (sin(2 * pi * freq * i / sr) * 32767 * 0.8 * env).toInt();
      buf.setInt16(44 + i * 2, s.clamp(-32768, 32767), Endian.little);
    }
    return buf.buffer.asUint8List();
  }

  // ── Timer logic ──────────────────────────────────────────────────────────

  void _start() {
    _currentSet = 1;
    _currentRep = 1;
    _isLeftHand = false;
    _paused = false;
    _setWeights.clear();
    _setWeights[1] = double.tryParse(_weightCtrl.text) ?? 0;
    _enterPhase(_Phase.getReady, 5);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _enterPhase(_Phase phase, int seconds) {
    _phase = phase;
    _secondsLeft = seconds;
    _phaseDuration = seconds;
    setState(() {});
  }

  void _tick() {
    if (_paused) return;

    _secondsLeft--;

    // Countdown beeps before work
    if (_secondsLeft <= 3 &&
        _secondsLeft > 0 &&
        (_phase == _Phase.getReady ||
            _phase == _Phase.rest ||
            _phase == _Phase.switchRest ||
            _phase == _Phase.setRest)) {
      _playBeep(_tickBeep);
      HapticFeedback.lightImpact();
    }

    if (_secondsLeft <= 0) {
      _advance();
    }
    setState(() {});
  }

  void _advance() {
    switch (_phase) {
      case _Phase.getReady:
      case _Phase.rest:
        if (_phase == _Phase.rest) _currentRep++;
        _startWork();
      case _Phase.switchRest:
        _isLeftHand = true;
        _startWork();
      case _Phase.work:
        if (_rlMode && !_isLeftHand) {
          _playBeep(_lowBeep);
          _enterPhase(_Phase.switchRest, _switchRestSecs);
        } else {
          _isLeftHand = false;
          if (_currentRep < _reps) {
            _playBeep(_lowBeep);
            _enterPhase(_Phase.rest, _restSecs);
          } else {
            _recordSetWeight();
            if (_currentSet < _sets) {
              _playBeep(_lowBeep);
              _enterPhase(_Phase.setRest, _setRestSecs);
            } else {
              _timer?.cancel();
              _playBeep(_doneBeep);
              HapticFeedback.heavyImpact();
              _enterPhase(_Phase.done, 0);
            }
          }
        }
      default:
        break;
    }
  }

  void _startWork() {
    _playBeep(_highBeep);
    HapticFeedback.mediumImpact();
    _enterPhase(_Phase.work, _workSecs);
  }

  void _recordSetWeight() {
    _setWeights[_currentSet] =
        double.tryParse(_weightCtrl.text) ?? 0;
  }

  void _togglePause() => setState(() => _paused = !_paused);

  void _stop() {
    _timer?.cancel();
    setState(() => _phase = _Phase.idle);
  }

  void _skipSetRest() {
    if (_phase == _Phase.setRest) {
      _recordSetWeight();
      _currentSet++;
      _currentRep = 1;
      _startWork();
    }
  }

  // ── Save to database ─────────────────────────────────────────────────────

  Future<void> _save() async {
    final db = ref.read(dbProvider);
    final catId = widget.categoryId ??
        _selectedCategoryId ??
        await db.insertOrGetCategory('Hangboard', groupName: 'Hangboard');
    final dateStr = dateStrFrom(DateTime.now());
    final baseTs = DateTime.now().millisecondsSinceEpoch;

    for (final entry in _setWeights.entries) {
      await db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: catId,
        dateStr: dateStr,
        timestamp: baseTs + entry.key,
        weightKg: Value(entry.value),
        reps: Value(_reps),
        timeSecs: Value(_workSecs),
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Saved ${_setWeights.length} sets')),
      );
      if (widget.categoryId != null) {
        Navigator.pop(context);
      } else {
        setState(() => _phase = _Phase.idle);
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final catName = widget.categoryId != null
        ? ref.watch(categoryByIdProvider(widget.categoryId!)).value?.name
        : null;
    final title = catName ?? 'Hangboard Timer';

    return Scaffold(
      appBar: _phase == _Phase.idle || _phase == _Phase.done
          ? AppBar(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)))
          : null,
      body: SafeArea(
        child: _phase == _Phase.idle
            ? _buildConfig(primary)
            : _phase == _Phase.done
                ? _buildDone(primary)
                : _buildTimer(primary),
      ),
    );
  }

  // ── Config panel ─────────────────────────────────────────────────────────

  Widget _buildConfig(Color primary) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        _stepper('Sets', _sets, 1, 20, (v) => _sets = v),
        _stepper('Reps', _reps, 1, 20, (v) => _reps = v),
        _stepper('Work', _workSecs, 1, 30, (v) => _workSecs = v,
            suffix: 's'),
        _stepper('Rest', _restSecs, 1, 60, (v) => _restSecs = v,
            suffix: 's'),
        _stepper('Set rest', _setRestSecs, 10, 600, (v) => _setRestSecs = v,
            suffix: 's', step: 10, format: _fmtDuration),

        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Right / Left mode'),
          subtitle: Text(
              'Alternate hands each rep',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4))),
          value: _rlMode,
          onChanged: (v) => setState(() => _rlMode = v),
        ),
        if (_rlMode)
          _stepper(
              'Switch rest', _switchRestSecs, 1, 60, (v) => _switchRestSecs = v,
              suffix: 's'),

        // ── Exercise picker (standalone mode only) ──────────────────────
        if (widget.categoryId == null) ...[
          const SizedBox(height: 16),
          _ExercisePicker(
            selectedId: _selectedCategoryId,
            onChanged: (id) => setState(() => _selectedCategoryId = id),
          ),
        ],

        const SizedBox(height: 16),
        Row(
          children: [
            Text('Weight',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixText: 'kg',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('START'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _stepper(
    String label,
    int value,
    int min,
    int max,
    void Function(int) onChanged, {
    String suffix = '',
    int step = 1,
    String Function(int)? format,
  }) {
    final display = format != null ? format(value) : '$value$suffix';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8))),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            color: Colors.white54,
            onPressed: value > min
                ? () => setState(() => onChanged((value - step).clamp(min, max)))
                : null,
          ),
          SizedBox(
            width: 56,
            child: Text(display,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            color: Colors.white54,
            onPressed: value < max
                ? () => setState(() => onChanged((value + step).clamp(min, max)))
                : null,
          ),
        ],
      ),
    );
  }

  static String _fmtDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  // ── Active timer ─────────────────────────────────────────────────────────

  Widget _buildTimer(Color primary) {
    final phaseColor = switch (_phase) {
      _Phase.work => const Color(0xFF43A047),
      _Phase.rest => const Color(0xFFFF7043),
      _Phase.switchRest => const Color(0xFFFFA726),
      _Phase.setRest => const Color(0xFF42A5F5),
      _Phase.getReady => Colors.white70,
      _ => primary,
    };

    final phaseLabel = switch (_phase) {
      _Phase.getReady => 'GET READY',
      _Phase.work => 'HANG',
      _Phase.rest => 'REST',
      _Phase.switchRest => 'SWITCH HANDS',
      _Phase.setRest => 'SET REST',
      _ => '',
    };

    final handLabel = _rlMode && _phase == _Phase.work
        ? (_isLeftHand ? 'LEFT HAND' : 'RIGHT HAND')
        : null;

    final progress = _phaseDuration > 0
        ? 1.0 - (_secondsLeft / _phaseDuration)
        : 0.0;

    return Column(
      children: [
        const SizedBox(height: 24),
        // Progress info
        Text(
          'Set $_currentSet/$_sets   Rep $_currentRep/$_reps',
          style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1),
        ),

        const Spacer(),

        // Phase label
        Text(phaseLabel,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: phaseColor,
                letterSpacing: 2)),
        const SizedBox(height: 16),

        // Big countdown
        Text(
          _phase == _Phase.setRest
              ? _fmtDuration(_secondsLeft)
              : '$_secondsLeft',
          style: TextStyle(
            fontSize: _phase == _Phase.setRest ? 64 : 96,
            fontWeight: FontWeight.w800,
            color: phaseColor,
          ),
        ),
        const SizedBox(height: 16),

        // Hand indicator
        if (handLabel != null)
          Text(handLabel,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1)),

        const SizedBox(height: 24),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              color: phaseColor,
            ),
          ),
        ),

        // Weight input during set rest
        if (_phase == _Phase.setRest) ...[
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Weight:',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6))),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    suffixText: 'kg',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipSetRest,
            child: const Text('SKIP REST'),
          ),
        ],

        const Spacer(),

        // Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                label: const Text('STOP'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                  minimumSize: const Size(120, 48),
                ),
              ),
              FilledButton.icon(
                onPressed: _togglePause,
                icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                label: Text(_paused ? 'RESUME' : 'PAUSE'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Done screen ──────────────────────────────────────────────────────────

  Widget _buildDone(Color primary) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        const SizedBox(height: 16),
        Text('WORKOUT COMPLETE',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primary,
                letterSpacing: 2)),
        const SizedBox(height: 24),
        Text(
          '$_sets sets  ×  $_reps reps\n'
          '${_workSecs}s work / ${_restSecs}s rest'
          '${_rlMode ? ' (R/L)' : ''}',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 24),

        // Weight per set (editable before save)
        ...List.generate(_sets, (i) {
          final set = i + 1;
          final w = _setWeights[set] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text('Set $set',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.7))),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: TextEditingController(text: w.toString()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: 'kg',
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        _setWeights[set] = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('SAVE TO LOG'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _stop,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white54,
            side: const BorderSide(color: Colors.white24),
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('DISCARD'),
        ),
      ],
    );
  }
}

// ── Exercise picker for standalone mode ──────────────────────────────────────

class _ExercisePicker extends ConsumerWidget {
  final int? selectedId;
  final void Function(int?) onChanged;
  const _ExercisePicker({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    // Show hangboard exercises (type 2) first, then all others
    final hangboard = categories.where((c) => c.exerciseType == 2).toList();
    final others = categories.where((c) => c.exerciseType != 2).toList();
    final items = [...hangboard, ...others];

    return Row(
      children: [
        Text('Exercise',
            style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true),
            hint: const Text('Hangboard (default)'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Hangboard (default)'),
              ),
              ...items.map((c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
