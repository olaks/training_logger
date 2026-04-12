import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/share_file.dart';

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
        .firstWhere((w) => w.id == id, orElse: () => Workout(id: id, name: '?', notes: ''));

    final sortedDates = byDate.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (plan != null)
            PopupMenuButton<_DetailAction>(
              icon: const Icon(Icons.more_vert),
              onSelected: (a) {
                if (a == _DetailAction.rename) {
                  _showRenameDialog(context, ref, plan.id, plan.name);
                } else if (a == _DetailAction.export) {
                  _exportPlan(context, ref, plan.id, plan.name);
                } else {
                  _showDeleteDialog(context, ref, plan.id, plan.name);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: _DetailAction.rename, child: Text('Rename')),
                PopupMenuItem(value: _DetailAction.export, child: Text('Export plan')),
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

  Future<void> _exportPlan(
      BuildContext context, WidgetRef ref, int id, String name) async {
    try {
      final json = await ref.read(dbProvider).exportPlanToJson(id);
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      await shareJsonFile(json, 'plan_${safeName}_${dateStrFrom(DateTime.now())}.json');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
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

class _PickWorkoutSheet extends ConsumerStatefulWidget {
  final Future<void> Function(int workoutId) onPick;
  const _PickWorkoutSheet({required this.onPick});

  @override
  ConsumerState<_PickWorkoutSheet> createState() => _PickWorkoutSheetState();
}

class _PickWorkoutSheetState extends ConsumerState<_PickWorkoutSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workouts  = ref.watch(allWorkoutsProvider).value ?? [];
    final exercises = ref.watch(categoriesProvider).value ?? [];
    final primary   = Theme.of(context).colorScheme.primary;

    final q = _query.toLowerCase();
    final filteredWorkouts = q.isEmpty
        ? workouts
        : workouts.where((w) => w.name.toLowerCase().contains(q)).toList();
    final filteredExercises = q.isEmpty
        ? exercises
        : exercises.where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.groupName?.toLowerCase().contains(q) ?? false)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search workouts or exercises',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: ctrl,
              children: [
                // ── Workouts section ────────────────────────────────────
                if (filteredWorkouts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text('WORKOUTS',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: primary)),
                  ),
                  ...filteredWorkouts.map((w) => ListTile(
                        leading: const Icon(Icons.list_alt, size: 20),
                        title: Text(w.name),
                        dense: true,
                        onTap: () => widget.onPick(w.id),
                      )),
                ],

                // ── Exercises section ───────────────────────────────────
                if (filteredExercises.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text('SINGLE EXERCISE',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w700,
                            color: primary)),
                  ),
                  ...filteredExercises.map((cat) => ListTile(
                        leading: const Icon(Icons.fitness_center, size: 20),
                        title: Text(cat.name),
                        subtitle: cat.groupName != null
                            ? Text(cat.groupName!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.4)))
                            : null,
                        dense: true,
                        onTap: () async {
                          final db = ref.read(dbProvider);
                          final wId = await db.getOrCreateWorkoutForExercise(
                              cat.id, cat.name);
                          await widget.onPick(wId);
                        },
                      )),
                ],
              ],
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

enum _DetailAction { rename, export, delete }
