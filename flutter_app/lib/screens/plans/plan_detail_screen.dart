import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';

class PlanDetailScreen extends ConsumerWidget {
  final int planId;
  const PlanDetailScreen({super.key, required this.planId});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(allPlansProvider).value
        ?.firstWhere((p) => p.id == planId, orElse: () => Plan(id: planId, name: ''));
    final allPlanWorkouts = ref.watch(planWorkoutsProvider(planId)).value ?? [];
    final allWorkouts     = ref.watch(allWorkoutsProvider).value ?? [];

    // Group by weekday (recurring) and dateStr (specific dates)
    final byWeekday = <int, List<PlanWorkout>>{};
    final byDate    = <String, List<PlanWorkout>>{};
    for (final pw in allPlanWorkouts) {
      if (pw.weekday != null) {
        byWeekday.putIfAbsent(pw.weekday!, () => []).add(pw);
      } else if (pw.dateStr != null) {
        byDate.putIfAbsent(pw.dateStr!, () => []).add(pw);
      }
    }

    Workout workoutById(int id) => allWorkouts
        .firstWhere((w) => w.id == id, orElse: () => Workout(id: id, name: '?'));

    final sortedDates = byDate.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (plan != null)
            PopupMenuButton<_DetailAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (a) => a == _DetailAction.rename
                  ? _showRenameDialog(context, ref, plan.id, plan.name)
                  : _showDeleteDialog(context, ref, plan.id, plan.name),
              itemBuilder: (_) => const [
                PopupMenuItem(value: _DetailAction.rename, child: Text('Rename')),
                PopupMenuItem(value: _DetailAction.delete, child: Text('Delete plan')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Weekly schedule ─────────────────────────────────────────────
          _SectionHeader(title: 'WEEKLY SCHEDULE'),
          const SizedBox(height: 4),
          ...List.generate(7, (i) {
            final wd  = i + 1;
            final pws = byWeekday[wd] ?? [];
            return _DayRow(
              label: _days[i],
              assignments: pws
                  .map((pw) => (id: pw.id, workout: workoutById(pw.workoutId)))
                  .toList(),
              onAdd: () => _showAddWorkoutSheet(context, ref, weekday: wd),
              onRemove: (id) => ref.removeWorkoutFromPlan(id),
              onTap: (workoutId) => context.push('/workouts/$workoutId'),
            );
          }),

          const SizedBox(height: 24),

          // ── Specific dates ──────────────────────────────────────────────
          Row(
            children: [
              _SectionHeader(title: 'SPECIFIC DATES'),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _pickDate(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add date'),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),

          if (sortedDates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No specific dates.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ...sortedDates.expand((dateStr) {
              final pws = byDate[dateStr]!;
              return [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(dateStr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...pws.map((pw) {
                      final w = workoutById(pw.workoutId);
                      return InputChip(
                        label: Text(w.name),
                        onDeleted: () => ref.removeWorkoutFromPlan(pw.id),
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 14),
                      label: const Text('Add'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          _showAddWorkoutSheet(context, ref, dateStr: dateStr),
                    ),
                  ],
                ),
              ];
            }),
        ],
      ),
    );
  }

  void _showAddWorkoutSheet(BuildContext context, WidgetRef ref,
      {int? weekday, String? dateStr}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PickWorkoutSheet(
        onPick: (workoutId) async {
          await ref.assignWorkoutToPlan(planId, workoutId,
              weekday: weekday, dateStr: dateStr);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null || !context.mounted) return;
    _showAddWorkoutSheet(context, ref, dateStr: dateStrFrom(picked));
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, int id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Rename Plan'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Plan name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _rename(context, ref, id, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _rename(context, ref, id, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _rename(BuildContext context, WidgetRef ref, int id, String name) {
    if (name.trim().isEmpty) return;
    ref.renamePlan(id, name.trim());
    Navigator.pop(context);
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text(
            'All workout assignments in this plan will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.deletePlan(id);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) context.pop();
            },
            child: Text('Delete',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Day row ───────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String label;
  final List<({int id, Workout workout})> assignments;
  final VoidCallback onAdd;
  final void Function(int assignmentId) onRemove;
  final void Function(int workoutId) onTap;

  const _DayRow({
    required this.label,
    required this.assignments,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6))),
            ),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...assignments.map((a) => InputChip(
                        label: Text(a.workout.name),
                        onDeleted: () => onRemove(a.id),
                        onPressed: () => onTap(a.workout.id),
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 14),
                    label: const Text('Add'),
                    visualDensity: VisualDensity.compact,
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Pick workout sheet ────────────────────────────────────────────────────────

class _PickWorkoutSheet extends ConsumerWidget {
  final Future<void> Function(int workoutId) onPick;
  const _PickWorkoutSheet({required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(allWorkoutsProvider).value ?? [];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select workout',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          if (workouts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  'No workouts yet. Create one in the Plans tab first.'),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: workouts.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(workouts[i].name),
                  onTap: () => onPick(workouts[i].id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}

enum _DetailAction { rename, delete }
