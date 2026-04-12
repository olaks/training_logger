import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final int workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(allWorkoutsProvider).value
        ?.firstWhere((w) => w.id == workoutId,
            orElse: () => Workout(id: workoutId, name: ''));
    final exercises = ref.watch(workoutExercisesProvider(workoutId)).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(workout?.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (workout != null)
            PopupMenuButton<_Action>(
              icon: const Icon(Icons.more_vert),
              onSelected: (a) => a == _Action.rename
                  ? _showRenameDialog(context, ref, workout.id, workout.name)
                  : _showDeleteDialog(context, ref, workout.id, workout.name),
              itemBuilder: (_) => const [
                PopupMenuItem(value: _Action.rename, child: Text('Rename')),
                PopupMenuItem(
                    value: _Action.delete, child: Text('Delete workout')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        children: [
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('No exercises yet.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ...exercises.map((entry) {
              final (cat, targetReps) = entry;
              return ListTile(
                title: Text(cat.name),
                subtitle: cat.groupName != null
                    ? Text(cat.groupName!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.45)))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditRepsDialog(
                          context, ref, cat.id, targetReps),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          targetReps != null
                              ? '× $targetReps reps'
                              : 'set reps',
                          style: TextStyle(
                            fontSize: 13,
                            color: targetReps != null
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: Colors.white54,
                      onPressed: () =>
                          ref.removeExerciseFromWorkout(workoutId, cat.id),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showAddExercisesSheet(context, ref, exercises),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add exercises'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditRepsDialog(
      BuildContext context, WidgetRef ref, int catId, int? current) {
    final ctrl = TextEditingController(text: current?.toString() ?? '');
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Target reps'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Reps', hintText: 'Leave empty to clear'),
          onSubmitted: (_) => _saveReps(dialogCtx, ref, catId, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _saveReps(dialogCtx, ref, catId, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _saveReps(
      BuildContext context, WidgetRef ref, int catId, String text) {
    final reps =
        text.trim().isEmpty ? null : int.tryParse(text.trim());
    ref.updateWorkoutTargetReps(workoutId, catId, reps);
    Navigator.pop(context);
  }

  void _showAddExercisesSheet(BuildContext context, WidgetRef ref,
      List<(ExerciseCategory, int?)> exercises) {
    final current = exercises.map((e) => e.$1).toList();
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddExercisesSheet(
        workoutId: workoutId,
        current: current,
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, int id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Rename Workout'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Workout name'),
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
    ref.renameWorkout(id, name.trim());
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
            'All exercises in this workout will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.deleteWorkout(id);
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

// ── Add exercises bottom sheet ─────────────────────────────────────────────────

class _AddExercisesSheet extends ConsumerStatefulWidget {
  final int workoutId;
  final List<ExerciseCategory> current;
  const _AddExercisesSheet(
      {required this.workoutId, required this.current});

  @override
  ConsumerState<_AddExercisesSheet> createState() => _AddExercisesSheetState();
}

class _AddExercisesSheetState extends ConsumerState<_AddExercisesSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all        = ref.watch(categoriesProvider).value ?? [];
    final currentIds = widget.current.map((c) => c.id).toSet();

    // Filter by query (name or group)
    final visible = _query.isEmpty
        ? all
        : all.where((c) {
            final q = _query.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                (c.groupName?.toLowerCase().contains(q) ?? false);
          }).toList();

    // Group and sort (null group → 'Other' at end)
    final grouped = <String?, List<ExerciseCategory>>{};
    for (final cat in visible) {
      grouped.putIfAbsent(cat.groupName, () => []).add(cat);
    }
    final sortedGroups = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    // Flatten into mixed list: String = header, ExerciseCategory = row
    final items = <Object>[];
    for (final group in sortedGroups) {
      items.add(group ?? 'Other');
      items.addAll(grouped[group]!);
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),

          // Title + search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add exercises',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search exercises',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Grouped list
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: items.length + 1, // +1 for "New exercise" footer
              itemBuilder: (_, i) {
                if (i == items.length) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: TextButton.icon(
                      onPressed: _showCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('New exercise…'),
                    ),
                  );
                }

                final item = items[i];

                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      item.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }

                final cat      = item as ExerciseCategory;
                final inWorkout = currentIds.contains(cat.id);
                return CheckboxListTile(
                  dense: true,
                  value: inWorkout,
                  title: Text(cat.name),
                  onChanged: (_) {
                    if (inWorkout) {
                      ref.removeExerciseFromWorkout(widget.workoutId, cat.id);
                    } else {
                      ref.addExerciseToWorkout(widget.workoutId, cat.id);
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

  void _showCreateDialog() {
    final db        = ref.read(dbProvider);
    final nameCtrl  = TextEditingController();
    final groupCtrl = TextEditingController(text: _query.isNotEmpty
        ? (_groupFromQuery() ?? '')
        : '');

    // Existing group names for autocomplete
    final groups = (ref.read(categoriesProvider).value ?? [])
        .map((c) => c.groupName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    Future<void> doCreate(BuildContext dialogCtx) async {
      final name  = nameCtrl.text.trim();
      if (name.isEmpty) return;
      final group = groupCtrl.text.trim().isEmpty ? null : groupCtrl.text.trim();
      final catId = await db.insertOrGetCategory(name, groupName: group);
      await db.addExerciseToWorkout(widget.workoutId, catId);
      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
    }

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('New Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Exercise name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => doCreate(dialogCtx),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue: TextEditingValue(text: groupCtrl.text),
              optionsBuilder: (v) => groups.where(
                  (g) => g.toLowerCase().contains(v.text.toLowerCase())),
              onSelected: (g) => groupCtrl.text = g,
              fieldViewBuilder: (_, autoCtrl, focus, __) {
                autoCtrl.addListener(() => groupCtrl.text = autoCtrl.text);
                return TextField(
                  controller: autoCtrl,
                  focusNode: focus,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'e.g. Bouldering, Core…',
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => groupCtrl.text = v,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => doCreate(dialogCtx),
              child: const Text('Add')),
        ],
      ),
    );
  }

  /// If the current search query exactly matches a known group name, return it
  /// so the new-exercise dialog can pre-fill the category field.
  String? _groupFromQuery() {
    final groups = (ref.read(categoriesProvider).value ?? [])
        .map((c) => c.groupName)
        .whereType<String>();
    return groups.firstWhere(
      (g) => g.toLowerCase() == _query.toLowerCase(),
      orElse: () => '',
    ).isEmpty ? null : _query;
  }
}

enum _Action { rename, delete }
