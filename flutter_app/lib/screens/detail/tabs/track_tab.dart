import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/grades.dart';

class TrackTab extends ConsumerStatefulWidget {
  final int    categoryId;
  final String dateStr;
  const TrackTab({super.key, required this.categoryId, required this.dateStr});

  @override
  ConsumerState<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends ConsumerState<TrackTab> {
  static const _restOptions = [60, 120, 180, 300]; // 1 2 3 5 min

  bool _prefilled = false;

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
    final cat       = ref.watch(categoryByIdProvider(widget.categoryId)).value;
    final isClimbing = cat?.exerciseType == 1;
    final imageData  = cat?.imageData;

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

          // Save / Clear
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (isClimbing) {
                      if (state.gradeIndex < 0) return;
                      await ref.saveSet(
                        categoryId: widget.categoryId,
                        dateStr:    widget.dateStr,
                        state:      state,
                        grade:      grades[state.gradeIndex],
                      );
                    } else {
                      await ref.saveSet(
                        categoryId: widget.categoryId,
                        dateStr:    widget.dateStr,
                        state:      state,
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
                Text(set.grade != null
                    ? set.grade!
                    : formatSet(
                        weightKg: set.weightKg,
                        reps:     set.reps,
                        timeSecs: set.timeSecs)),
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
