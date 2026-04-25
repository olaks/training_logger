import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/share_file.dart';

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class PlanDetailScreen extends ConsumerWidget {
  final int planId;
  const PlanDetailScreen({super.key, required this.planId});

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
        initialWeekday: weekday,
        onPick: (workoutId, selectedWeekdays) async {
          if (selectedWeekdays.isEmpty && dateStr == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select at least one day first.')),
            );
            return;
          }
          if (selectedWeekdays.isNotEmpty) {
            for (final wd in selectedWeekdays) {
              await ref.assignWorkoutToPlan(planId, workoutId, weekday: wd);
            }
          } else if (dateStr != null) {
            await ref.assignWorkoutToPlan(planId, workoutId, dateStr: dateStr);
          }
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

// ── Day row (collapsible) ─────────────────────────────────────────────────────

class _DayRow extends StatefulWidget {
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
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.assignments.isNotEmpty;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ───────────────────────────────────────────────
        InkWell(
          onTap: hasItems ? () => setState(() => _expanded = !_expanded) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(widget.label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6))),
                ),
                Expanded(
                  child: hasItems
                      ? Text(
                          _expanded
                              ? '${widget.assignments.length} workouts'
                              : widget.assignments
                                  .map((a) => a.workout.name)
                                  .join(', '),
                          style: TextStyle(
                              fontSize: 13,
                              color: _expanded
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.7)),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text('Rest',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.2))),
                ),
                if (hasItems)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    padding: EdgeInsets.zero,
                    color: primary,
                    onPressed: widget.onAdd,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expanded workout list ────────────────────────────────────
        if (_expanded && hasItems)
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 4),
            child: Column(
              children: widget.assignments.map((a) => SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTap(a.workout.id),
                        child: Text(a.workout.name,
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 14),
                        padding: EdgeInsets.zero,
                        color: Colors.white.withValues(alpha: 0.3),
                        onPressed: () => widget.onRemove(a.id),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

// ── Pick workout sheet ────────────────────────────────────────────────────────

class _PickWorkoutSheet extends ConsumerStatefulWidget {
  final Future<void> Function(int workoutId, List<int> weekdays) onPick;
  final int? initialWeekday;
  const _PickWorkoutSheet({required this.onPick, this.initialWeekday});

  @override
  ConsumerState<_PickWorkoutSheet> createState() => _PickWorkoutSheetState();
}

class _PickWorkoutSheetState extends ConsumerState<_PickWorkoutSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late final Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialWeekday != null
        ? {widget.initialWeekday!}
        : {};
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _pick(int workoutId) =>
      widget.onPick(workoutId, _selectedDays.toList()..sort());

  @override
  Widget build(BuildContext context) {
    final workouts  = ref.watch(allWorkoutsProvider).value ?? [];
    final exercises = ref.watch(categoriesProvider).value ?? [];
    final primary   = Theme.of(context).colorScheme.primary;
    final showDayPicker = widget.initialWeekday != null;

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

          // ── Day picker (weekday mode only) ──────────────────────────
          if (showDayPicker)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (i) {
                  final wd = i + 1;
                  final selected = _selectedDays.contains(wd);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedDays.remove(wd);
                      } else {
                        _selectedDays.add(wd);
                      }
                    }),
                    child: Container(
                      width: 40,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? primary.withValues(alpha: 0.25)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? primary
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _days[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected
                              ? primary
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

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
                        onTap: () => _pick(w.id),
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
                          _pick(wId);
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
