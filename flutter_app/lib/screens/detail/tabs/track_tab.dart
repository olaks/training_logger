import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/beeper.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/grades.dart';

// ── Timed-set timer phases ───────────────────────────────────────────────────

enum _ExPhase { idle, getReady, work }

class TrackTab extends ConsumerStatefulWidget {
  final int    categoryId;
  final String dateStr;
  const TrackTab({super.key, required this.categoryId, required this.dateStr});

  @override
  ConsumerState<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends ConsumerState<TrackTab> {
  static const _restOptions = [60, 120, 180, 300]; // 1 2 3 5 min
  static const _getReadySecs = 5;

  bool _prefilled = false;

  // ── Timed-set timer ───────────────────────────────────────────────────────
  // Only used by standard exercises that have a TIME value set. Countdown is
  // anchored to wall-clock time so OS scheduling jitter and platform-channel
  // work (audio, haptics) can't make it drift.
  Beeper?   _beeper;
  Timer?    _exTimer;
  _ExPhase  _exPhase = _ExPhase.idle;
  DateTime? _exPhaseEnd;      // wall-clock time the current phase ends
  int       _exPhaseSecs = 0; // total seconds for current phase (progress)
  int       _exLastBeeped = -1;
  int       _exWorkSecs = 0;

  bool get _exRunning => _exPhase != _ExPhase.idle;

  @override
  void dispose() {
    _exTimer?.cancel();
    if (_exRunning) WakelockPlus.disable();
    _beeper?.dispose();
    super.dispose();
  }

  /// Runs a [workSecs] hold after a 5-second get-ready countdown, then logs
  /// the set and starts the rest timer.
  void _startExerciseTimer(int workSecs) {
    FocusScope.of(context).unfocus();
    ref.read(restTimerProvider.notifier).cancel();
    _beeper ??= Beeper();
    _exWorkSecs = workSecs;
    WakelockPlus.enable();
    _enterExPhase(_ExPhase.getReady, _getReadySecs);
    _exTimer?.cancel();
    _exTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) => _exTick());
  }

  void _enterExPhase(_ExPhase phase, int seconds) {
    _exPhase = phase;
    _exPhaseSecs = seconds;
    _exPhaseEnd = DateTime.now().add(Duration(seconds: seconds));
    _exLastBeeped = -1;
    setState(() {});
  }

  void _exTick() {
    if (_exPhaseEnd == null) return;

    final remainingMs = _exPhaseEnd!.difference(DateTime.now()).inMilliseconds;
    if (remainingMs <= 0) {
      _exAdvance();
      return;
    }

    final secsLeft = (remainingMs / 1000).ceil();
    if (secsLeft != _exLastBeeped && secsLeft >= 1 && secsLeft <= 3) {
      _beeper?.tick();
      HapticFeedback.lightImpact();
      _exLastBeeped = secsLeft;
    }

    setState(() {});
  }

  void _exAdvance() {
    switch (_exPhase) {
      case _ExPhase.getReady:
        _beeper?.high();
        HapticFeedback.mediumImpact();
        _enterExPhase(_ExPhase.work, _exWorkSecs);
      case _ExPhase.work:
        _exTimer?.cancel();
        WakelockPlus.disable();
        _beeper?.done();
        HapticFeedback.heavyImpact();
        setState(() {
          _exPhase = _ExPhase.idle;
          _exPhaseEnd = null;
        });
        // Nothing is written here — the set is only logged when SAVE is
        // tapped, so a hold that didn't go the distance can be corrected
        // first.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hold complete — ${_exWorkSecs}s. '
              'Tap SAVE to log it.'),
          duration: const Duration(seconds: 3),
        ));
      case _ExPhase.idle:
        break;
    }
  }

  /// Cancels the timer. Stopping mid-hold drops the actual time held into the
  /// TIME field, so a short hold can be saved as what really happened.
  void _stopExerciseTimer() {
    final held = _exPhase == _ExPhase.work ? _heldSecs() : 0;
    _exTimer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _exPhase = _ExPhase.idle;
      _exPhaseEnd = null;
    });
    if (held > 0) {
      ref.read(trackProvider(widget.categoryId).notifier).setTimeSecs(held);
    }
  }

  /// Seconds elapsed in the current hold phase.
  int _heldSecs() {
    final remainingMs =
        _exPhaseEnd?.difference(DateTime.now()).inMilliseconds ?? 0;
    final elapsedMs =
        _exWorkSecs * 1000 - (remainingMs < 0 ? 0 : remainingMs);
    return (elapsedMs / 1000).round().clamp(0, _exWorkSecs);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _weightEditStr(double v) {
    if (v == 0) return '';
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  }

  static String _rpeLabel(int rpe) => switch (rpe) {
        0           => '—',
        1 || 2 || 3 => 'Easy',
        4 || 5      => 'Moderate',
        6 || 7      => 'Hard',
        8 || 9      => 'Very Hard',
        _           => 'Max',
      };

  static String _targetLabel(int? sets, int? reps, int done) {
    final parts = <String>[];
    if (sets != null && reps != null) {
      parts.add('Target: $sets \u00d7 $reps reps');
    } else if (sets != null) {
      parts.add('Target: $sets sets');
    } else if (reps != null) {
      parts.add('Target: $reps reps');
    }
    if (sets != null && done > 0) {
      parts.add(done >= sets
          ? '\u2014 complete'
          : '\u2014 $done of $sets done');
    }
    return parts.join(' ');
  }

  /// Fill the form from a [WorkoutSet], using the given grade scale.
  void _fillFrom(WorkoutSet s, TrackNotifier notifier, List<String> grades, bool isClimbing) {
    if (isClimbing && s.grade != null) {
      notifier.setGradeIndex(gradeToIndex(s.grade!, grades));
      notifier.setWallAngle(s.wallAngle ?? 0);
      notifier.setClimbName(s.climbName ?? '');
    } else {
      notifier.setWeight(s.weightKg ?? 0);
      notifier.setReps(s.reps ?? 0);
      notifier.setTimeSecs(s.timeSecs ?? 0);
    }
    notifier.setRpe(s.rpe ?? 0);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('Delete this set?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.removeSet(id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cat        = ref.watch(categoryByIdProvider(widget.categoryId)).value;
    final isClimbing = cat?.exerciseType == 1;
    final isHangboard = cat?.exerciseType == 2;
    final imageData  = cat?.imageData;

    // For hangboard exercises, show a simplified view with timer launch
    if (isHangboard) {
      return _buildHangboardTrack(context, ref, cat!, imageData);
    }

    final state    = ref.watch(trackProvider(widget.categoryId));
    final notifier = ref.read(trackProvider(widget.categoryId).notifier);
    final todaySets = ref.watch(setsForDayProvider(widget.dateStr)).value
            ?.where((s) => s.categoryId == widget.categoryId).toList() ??
        [];
    final displayDate =
        DateFormat('MMM d').format(dateFromStr(widget.dateStr));
    final primary = Theme.of(context).colorScheme.primary;

    // Detect grade scale from any already-logged grades (or default Font)
    final allSets = ref.watch(setsForCategoryProvider(widget.categoryId)).value ?? [];
    final loggedGrades = allSets
        .where((s) => s.grade != null)
        .map((s) => s.grade!);
    final grades = detectGradeScale(loggedGrades);

    // Rest timer (global provider)
    final timerState   = ref.watch(restTimerProvider);
    final timerNotifier = ref.read(restTimerProvider.notifier);

    // Workout target for this exercise on this date
    final target = ref.watch(exerciseTargetProvider(
        (categoryId: widget.categoryId, dateStr: widget.dateStr))).value;
    final targetSets = target?.$1;
    final targetReps = target?.$2;

    // ── Pre-fill from last set ────────────────────────────────────────────
    if (!_prefilled && (todaySets.isNotEmpty || allSets.isNotEmpty)) {
      _prefilled = true;
      final source = todaySets.isNotEmpty ? todaySets.last : allSets.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fillFrom(source, notifier, grades, isClimbing);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageData != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(imageData,
                  width: double.infinity, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
          ],
          Text(displayDate,
              style: TextStyle(fontSize: 12, color: primary, letterSpacing: 1)),
          const SizedBox(height: 20),

          if (isClimbing)
            _buildClimbingInputs(context, state, notifier, grades, primary)
          else
            _buildStandardInputs(context, state, notifier, primary),

          const SizedBox(height: 28),

          // ── Timed-set countdown (replaces the buttons while running) ─────
          if (_exRunning)
            _ExerciseTimerPanel(
              phase:     _exPhase,
              phaseSecs: _exPhaseSecs,
              phaseEnd:  _exPhaseEnd,
              onStop:    _stopExerciseTimer,
            )
          else
          // Save / Clear / Start
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // Yield so any focused stepper's focus-loss listener fires
                    // and commits the typed value into TrackNotifier before we
                    // read it. Otherwise we'd save the previous (stale) value.
                    await Future<void>.delayed(Duration.zero);
                    if (!context.mounted) return;
                    final current = ref.read(trackProvider(widget.categoryId));
                    if (isClimbing) {
                      if (current.gradeIndex < 0) return;
                      await ref.saveSet(
                        categoryId: widget.categoryId,
                        dateStr:    widget.dateStr,
                        state:      current,
                        grade:      grades[current.gradeIndex],
                      );
                    } else {
                      await ref.saveSet(
                        categoryId: widget.categoryId,
                        dateStr:    widget.dateStr,
                        state:      current,
                      );
                    }
                    timerNotifier.start();
                  },
                  child: const Text('SAVE'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    notifier.clear();
                    timerNotifier.cancel();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CLEAR',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              // Timer mode — only meaningful once a hold duration is set.
              if (!isClimbing && state.timeSecs > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startExerciseTimer(state.timeSecs),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('START',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // ── Rest timer ──────────────────────────────────────────────────
          if (timerState.active) ...[
            const SizedBox(height: 20),
            _RestTimerWidget(
              remaining:    timerState.remaining,
              restSecs:     timerState.restSecs,
              restOptions:  _restOptions,
              onCancel:     timerNotifier.cancel,
              onSetDuration: timerNotifier.setDurationAndRestart,
            ),
          ],

          // Target + logged sets
          if (targetSets != null || targetReps != null || todaySets.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            if (targetSets != null || targetReps != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _targetLabel(targetSets, targetReps, todaySets.length),
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: todaySets.length >= (targetSets ?? 0) && todaySets.isNotEmpty
                          ? primary
                          : Colors.white.withValues(alpha: 0.5)),
                ),
              ),
            if (todaySets.isNotEmpty)
              Text('Logged today',
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            ...todaySets.asMap().entries.map(
              (e) => _LoggedSetRow(
                set: e.value,
                index: e.key,
                primary: primary,
                onTap: () => _fillFrom(e.value, notifier, grades, isClimbing),
                onDelete: () => _confirmDelete(context, ref, e.value.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClimbingInputs(
    BuildContext context,
    TrackState state,
    TrackNotifier notifier,
    List<String> grades,
    Color primary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade picker
        Text('GRADE',
            style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: primary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            _StepBtn(
              label: '−',
              onTap: notifier.decrementGrade,
            ),
            Expanded(
              child: Text(
                state.gradeIndex < 0 ? '—' : grades[state.gradeIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.w700,
                    letterSpacing: 1),
              ),
            ),
            _StepBtn(
              label: '+',
              onTap: () => notifier.incrementGrade(grades.length - 1),
            ),
          ],
        ),
        const Divider(height: 32),

        // Wall angle (degrees)
        _StepperRow(
          label:        'WALL ANGLE (°)',
          value:        state.wallAngle == 0 ? '—' : '${state.wallAngle}°',
          editValue:    state.wallAngle == 0 ? '' : '${state.wallAngle}',
          keyboardType: TextInputType.number,
          onDecrement:  notifier.decrementWallAngle,
          onIncrement:  notifier.incrementWallAngle,
          onTyped: (s) {
            final v = int.tryParse(s);
            if (v != null) notifier.setWallAngle(v);
          },
        ),
        const Divider(height: 32),

        // Climb name
        _ClimbNameField(
          value:   state.climbName,
          onChanged: notifier.setClimbName,
        ),
        const Divider(height: 32),

        // RPE
        _RpeRow(
          rpe:         state.rpe,
          label:       _rpeLabel(state.rpe),
          onDecrement: () => notifier.setRpe(state.rpe > 0 ? state.rpe - 1 : 0),
          onIncrement: () => notifier.setRpe(state.rpe < 10 ? state.rpe + 1 : 10),
        ),
      ],
    );
  }

  Widget _buildStandardInputs(
    BuildContext context,
    TrackState state,
    TrackNotifier notifier,
    Color primary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weight
        _StepperRow(
          label: state.weightKg < 0 ? 'WEIGHT (kg) — ASSISTED' : 'WEIGHT (kg)',
          value:        formatWeight(state.weightKg),
          editValue:    _weightEditStr(state.weightKg),
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
          onDecrement: notifier.decrementWeight,
          onIncrement: notifier.incrementWeight,
          onTyped: (s) {
            final v = double.tryParse(s);
            if (v != null) notifier.setWeight(v);
          },
        ),
        const Divider(height: 32),

        // Reps
        _StepperRow(
          label:        'REPS',
          value:        '${state.reps}',
          editValue:    state.reps == 0 ? '' : '${state.reps}',
          keyboardType: TextInputType.number,
          onDecrement:  notifier.decrementReps,
          onIncrement:  notifier.incrementReps,
          onTyped: (s) {
            final v = int.tryParse(s);
            if (v != null) notifier.setReps(v);
          },
        ),
        const Divider(height: 32),

        // Time
        _StepperRow(
          label:        'TIME (tap to enter seconds)',
          value:        state.timeSecs == 0 ? '0s' : formatTime(state.timeSecs),
          editValue:    state.timeSecs == 0 ? '' : '${state.timeSecs}',
          keyboardType: TextInputType.number,
          onDecrement:  notifier.decrementTime,
          onIncrement:  notifier.incrementTime,
          onTyped: (s) {
            final v = int.tryParse(s);
            if (v != null) notifier.setTimeSecs(v);
          },
        ),
        const Divider(height: 32),

        // RPE
        _RpeRow(
          rpe:         state.rpe,
          label:       _rpeLabel(state.rpe),
          onDecrement: () => notifier.setRpe(state.rpe > 0 ? state.rpe - 1 : 0),
          onIncrement: () => notifier.setRpe(state.rpe < 10 ? state.rpe + 1 : 10),
        ),
      ],
    );
  }

  // ── Hangboard track view ─────────────────────────────────────────────────

  Widget _buildHangboardTrack(
      BuildContext context, WidgetRef ref,
      ExerciseCategory cat, Uint8List? imageData) {
    final todaySets = ref.watch(setsForDayProvider(widget.dateStr)).value
            ?.where((s) => s.categoryId == widget.categoryId).toList() ??
        [];
    final displayDate =
        DateFormat('MMM d').format(dateFromStr(widget.dateStr));
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageData != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(imageData,
                  width: double.infinity, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
          ],
          Text(displayDate,
              style: TextStyle(fontSize: 12, color: primary, letterSpacing: 1)),
          const SizedBox(height: 24),

          // Launch timer button
          FilledButton.icon(
            onPressed: () => context.push(
                '/hangboard-session/${widget.categoryId}'),
            icon: const Icon(Icons.timer, size: 22),
            label: const Text('START HANGBOARD TIMER'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Logged sets
          if (todaySets.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 8),
            Text('Logged today',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            ...todaySets.asMap().entries.map(
              (e) => _LoggedSetRow(
                set: e.value,
                index: e.key,
                primary: primary,
                onTap: () {},
                onDelete: () => _confirmDelete(context, ref, e.value.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Climbing set summary ─────────────────────────────────────────────────────

String _formatClimbingSet(WorkoutSet s) {
  final parts = <String>[s.grade!];
  final name = s.climbName?.trim();
  if (name != null && name.isNotEmpty) parts.add(name);
  if (s.wallAngle != null) parts.add('${s.wallAngle}°');
  return parts.join(' · ');
}

// ── Climb name text field ────────────────────────────────────────────────────

class _ClimbNameField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ClimbNameField({required this.value, required this.onChanged});

  @override
  State<_ClimbNameField> createState() => _ClimbNameFieldState();
}

class _ClimbNameFieldState extends State<_ClimbNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _ClimbNameField old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CLIMB NAME',
            style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: primary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'optional',
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

// ── Logged set row (tappable + deletable) ────────────────────────────────────

class _LoggedSetRow extends StatelessWidget {
  final WorkoutSet set;
  final int index;
  final Color primary;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _LoggedSetRow({
    required this.set,
    required this.index,
    required this.primary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                Text('Set ${index + 1}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4))),
                const Spacer(),
                Flexible(
                  child: Text(
                    set.grade != null
                        ? _formatClimbingSet(set)
                        : formatSet(
                            weightKg: set.weightKg,
                            reps:     set.reps,
                            timeSecs: set.timeSecs),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (set.rpe != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('RPE ${set.rpe}',
                        style: TextStyle(
                            fontSize: 11, color: primary)),
                  ),
                ],
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.25)),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── RPE row ───────────────────────────────────────────────────────────────────

class _RpeRow extends StatelessWidget {
  final int rpe;
  final String label;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _RpeRow({
    required this.rpe,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RPE (EFFORT)',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              _StepBtn(label: '−', onTap: onDecrement),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      rpe == 0 ? '—' : '$rpe',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      rpe == 0 ? 'not set' : label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              _StepBtn(label: '+', onTap: onIncrement),
            ],
          ),
        ],
      );
}

// ── Timed-set countdown panel ────────────────────────────────────────────────

class _ExerciseTimerPanel extends StatelessWidget {
  final _ExPhase phase;
  final int phaseSecs;
  final DateTime? phaseEnd;
  final VoidCallback onStop;

  const _ExerciseTimerPanel({
    required this.phase,
    required this.phaseSecs,
    required this.phaseEnd,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final working = phase == _ExPhase.work;
    final color   = working ? const Color(0xFF43A047) : Colors.white70;

    // Derived from wall-clock so the number and the bar always agree,
    // regardless of timer-tick jitter.
    final remainingMs = phaseEnd == null
        ? 0
        : phaseEnd!.difference(DateTime.now()).inMilliseconds;
    final safeRem  = remainingMs < 0 ? 0 : remainingMs;
    final secs     = (safeRem / 1000).ceil();
    final progress = phaseSecs > 0
        ? 1.0 - (safeRem / (phaseSecs * 1000)).clamp(0.0, 1.0)
        : 0.0;

    // The whole panel is a stop target — on a failed hold you want to hit it
    // without aiming.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStop,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(working ? 'HOLD' : 'GET READY',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: color)),
            Text('$secs',
                style: TextStyle(
                    fontSize: 72, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white12,
                color: color,
              ),
            ),
            const SizedBox(height: 16),

            // Oversized stop target
            SizedBox(
              width: double.infinity,
              height: 96,
              child: FilledButton.icon(
                onPressed: onStop,
                icon: const Icon(Icons.stop, size: 36),
                label: const Text('STOP',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              working
                  ? 'Stop early to keep the time you actually held'
                  : 'Get into position',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rest timer widget ─────────────────────────────────────────────────────────

class _RestTimerWidget extends StatelessWidget {
  final int remaining;
  final int restSecs;
  final List<int> restOptions;
  final VoidCallback onCancel;
  final void Function(int) onSetDuration;

  const _RestTimerWidget({
    required this.remaining,
    required this.restSecs,
    required this.restOptions,
    required this.onCancel,
    required this.onSetDuration,
  });

  @override
  Widget build(BuildContext context) {
    final primary  = Theme.of(context).colorScheme.primary;
    final progress = remaining / restSecs;
    final done     = remaining == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(done ? Icons.check_circle : Icons.timer_outlined,
                  size: 18,
                  color: done ? primary : Colors.white70),
              const SizedBox(width: 8),
              Text(
                done ? 'Rest complete' : 'Rest  ${_fmt(remaining)}',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: done ? primary : Colors.white),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCancel,
                child: Icon(Icons.close,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
          if (!done) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.white12,
                color: primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: restOptions.map((s) {
              final selected = restSecs == s;
              return GestureDetector(
                onTap: () => onSetDuration(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? primary
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(_fmt(s),
                      style: TextStyle(
                          fontSize: 12,
                          color: selected ? primary : Colors.white60)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return m > 0 ? (s == 0 ? '${m}m' : '${m}m ${s}s') : '${s}s';
  }
}

// ── Stepper row with tap-to-type ──────────────────────────────────────────────

class _StepperRow extends StatefulWidget {
  final String label;
  final String value;
  final String editValue;
  final TextInputType keyboardType;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final void Function(String) onTyped;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.editValue,
    required this.keyboardType,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTyped,
  });

  @override
  State<_StepperRow> createState() => _StepperRowState();
}

class _StepperRowState extends State<_StepperRow> {
  bool _editing = false;
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController();
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _startEdit() {
    _ctrl.text = widget.editValue;
    _ctrl.selection =
        TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _commit() {
    if (!_editing) return;
    setState(() => _editing = false);
    widget.onTyped(_ctrl.text);
  }

  void _stepAndCommit(VoidCallback step) {
    if (_editing) _commit();
    step();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              _StepBtn(
                  label: '−',
                  onTap: () => _stepAndCommit(widget.onDecrement)),
              Expanded(
                child: _editing
                    ? TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        keyboardType: widget.keyboardType,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _commit(),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _startEdit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(widget.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
              ),
              _StepBtn(
                  label: '+',
                  onTap: () => _stepAndCommit(widget.onIncrement)),
            ],
          ),
        ],
      );
}

// ── Step button ───────────────────────────────────────────────────────────────

class _StepBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StepBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 52,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w300)),
            ),
          ),
        ),
      );
}
