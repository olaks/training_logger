import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';

class PlanDetailScreen extends ConsumerWidget {
  final int planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan      = ref.watch(allPlansProvider).value
        ?.firstWhere((p) => p.id == planId, orElse: () => Plan(id: planId, name: ''));
    final exercises = ref.watch(planExercisesProvider(planId)).value ?? [];
    final schedules = ref.watch(schedulesForPlanProvider(planId)).value ?? [];

    final weekdays   = schedules.where((s) => s.weekday != null).map((s) => s.weekday!).toSet();
    final dateSched  = schedules.where((s) => s.dateStr != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (plan != null)
            PopupMenuButton<_DetailAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                if (action == _DetailAction.rename) {
                  _showRenameDialog(context, ref, plan.id, plan.name);
                } else {
                  _showDeleteDialog(context, ref, plan.id, plan.name);
                }
              },
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
          // ── Exercises ──────────────────────────────────────────────────
          _SectionHeader(title: 'EXERCISES'),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No exercises yet.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ...exercises.map((cat) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(cat.name),
                  subtitle: cat.groupName != null
                      ? Text(cat.groupName!,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.45)))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    color: Colors.white54,
                    onPressed: () => ref.removeExerciseFromPlan(planId, cat.id),
                  ),
                )),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _showAddExercisesSheet(context, ref, exercises),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add exercises'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
            ),
          ),

          const SizedBox(height: 28),

          // ── Schedule ───────────────────────────────────────────────────
          _SectionHeader(title: 'SCHEDULE'),
          const SizedBox(height: 8),
          _WeekdayRow(
            active: weekdays,
            onToggle: (wd) => _toggleWeekday(ref, wd, weekdays, schedules),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Specific dates',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
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
          if (dateSched.isEmpty)
            Text('None',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35)))
          else
            ...dateSched.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.dateStr!),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.white54,
                    onPressed: () => ref.deleteSchedule(s.id),
                  ),
                )),
        ],
      ),
    );
  }

  // ── Add exercises bottom sheet ──────────────────────────────────────────

  void _showAddExercisesSheet(BuildContext context, WidgetRef ref,
      List<ExerciseCategory> currentExercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _AddExercisesSheet(
        planId: planId,
        current: currentExercises,
      ),
    );
  }

  // ── Weekday toggle ──────────────────────────────────────────────────────

  void _toggleWeekday(WidgetRef ref, int wd, Set<int> active,
      List<ScheduledPlan> schedules) {
    if (active.contains(wd)) {
      final id = schedules.firstWhere((s) => s.weekday == wd).id;
      ref.deleteSchedule(id);
    } else {
      ref.schedulePlanOnWeekday(planId, wd);
    }
  }

  // ── Date picker ─────────────────────────────────────────────────────────

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    ref.schedulePlanOnDate(planId, dateStrFrom(picked));
  }

  // ── Rename / Delete dialogs ─────────────────────────────────────────────

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, int id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
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
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
      builder: (_) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text('All exercises and schedules in this plan will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.deletePlan(id);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) Navigator.pop(context); // also pop detail screen
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Add exercises bottom sheet ────────────────────────────────────────────────

class _AddExercisesSheet extends ConsumerWidget {
  final int planId;
  final List<ExerciseCategory> current;
  const _AddExercisesSheet({required this.planId, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(categoriesProvider).value ?? [];
    final currentIds = current.map((c) => c.id).toSet();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Add exercises to plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: all.length,
              itemBuilder: (_, i) {
                final cat = all[i];
                final inPlan = currentIds.contains(cat.id);
                return CheckboxListTile(
                  value: inPlan,
                  title: Text(cat.name),
                  subtitle: cat.groupName != null
                      ? Text(cat.groupName!,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  onChanged: (_) {
                    if (inPlan) {
                      ref.removeExerciseFromPlan(planId, cat.id);
                    } else {
                      ref.addExerciseToPlan(planId, cat.id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekday row ───────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  final Set<int> active; // 1=Mon…7=Sun
  final void Function(int) onToggle;
  const _WeekdayRow({required this.active, required this.onToggle});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final wd = i + 1;
          final on = active.contains(wd);
          return GestureDetector(
            onTap: () => onToggle(wd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: on ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        }),
      );
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

enum _DetailAction { rename, delete }
