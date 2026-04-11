import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/format_utils.dart';

class TrackTab extends ConsumerWidget {
  final int    categoryId;
  final String dateStr;
  const TrackTab({super.key, required this.categoryId, required this.dateStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(trackProvider(categoryId));
    final notifier = ref.read(trackProvider(categoryId).notifier);
    final todaySets = ref.watch(setsForDayProvider(dateStr)).value
            ?.where((s) => s.categoryId == categoryId).toList() ??
        [];
    final imageData = ref.watch(categoryByIdProvider(categoryId)).value?.imageData;

    final displayDate = DateFormat('MMM d').format(dateFromStr(dateStr));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageData != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageData,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            displayDate,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1),
          ),
          const SizedBox(height: 20),

          // Weight
          _StepperRow(
            label: state.weightKg < 0 ? 'WEIGHT (kg) — ASSISTED' : 'WEIGHT (kg)',
            value:     formatWeight(state.weightKg),
            editValue: _weightEditStr(state.weightKg),
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
            label:     'REPS',
            value:     '${state.reps}',
            editValue: state.reps == 0 ? '' : '${state.reps}',
            keyboardType: TextInputType.number,
            onDecrement: notifier.decrementReps,
            onIncrement: notifier.incrementReps,
            onTyped: (s) {
              final v = int.tryParse(s);
              if (v != null) notifier.setReps(v);
            },
          ),
          const Divider(height: 32),

          // Time
          _StepperRow(
            label:     'TIME (tap to enter seconds)',
            value:     state.timeSecs == 0 ? '0s' : formatTime(state.timeSecs),
            editValue: state.timeSecs == 0 ? '' : '${state.timeSecs}',
            keyboardType: TextInputType.number,
            onDecrement: notifier.decrementTime,
            onIncrement: notifier.incrementTime,
            onTyped: (s) {
              final v = int.tryParse(s);
              if (v != null) notifier.setTimeSecs(v);
            },
          ),

          const SizedBox(height: 28),

          // Save / Clear
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    await ref.saveSet(
                        categoryId: categoryId,
                        dateStr: dateStr,
                        state: state);
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
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CLEAR',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),

          // Sets logged today
          if (todaySets.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Logged today',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            ...todaySets.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set ${e.key + 1}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                    Text(formatSet(
                        weightKg: e.value.weightKg,
                        reps:     e.value.reps,
                        timeSecs: e.value.timeSecs)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _weightEditStr(double v) {
    if (v == 0) return '';
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  }
}

// ── Stepper row with tap-to-type ──────────────────────────────────────────────

class _StepperRow extends StatefulWidget {
  final String label;
  final String value;       // formatted for display
  final String editValue;   // pre-filled when the text field opens
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
                                  fontSize: 32, fontWeight: FontWeight.w600)),
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
