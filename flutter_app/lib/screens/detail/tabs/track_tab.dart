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

    final displayDate = DateFormat('MMM d').format(dateFromStr(dateStr));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            value:       formatWeight(state.weightKg),
            onDecrement: notifier.decrementWeight,
            onIncrement: notifier.incrementWeight,
          ),
          const Divider(height: 32),

          // Reps
          _StepperRow(
            label:       'REPS',
            value:       '${state.reps}',
            onDecrement: notifier.decrementReps,
            onIncrement: notifier.incrementReps,
          ),
          const Divider(height: 32),

          // Time
          _StepperRow(
            label:       'TIME',
            value:       state.timeSecs == 0 ? '0s' : formatTime(state.timeSecs),
            onDecrement: notifier.decrementTime,
            onIncrement: notifier.incrementTime,
          ),

          const SizedBox(height: 28),

          // Save / Clear
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
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
                  onPressed: notifier.clear,
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
                    color: Colors.white.withValues(alpha:0.4))),
            const SizedBox(height: 8),
            ...todaySets.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Set ${e.key + 1}',
                        style: TextStyle(color: Colors.white.withValues(alpha:0.4))),
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
}

class _StepperRow extends StatelessWidget {
  final String label, value;
  final VoidCallback onDecrement, onIncrement;
  const _StepperRow(
      {required this.label,
      required this.value,
      required this.onDecrement,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
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
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600)),
              ),
              _StepBtn(label: '+', onTap: onIncrement),
            ],
          ),
        ],
      );
}

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
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w300)),
            ),
          ),
        ),
      );
}
