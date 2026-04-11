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
            ...exercises.map((cat) => ListTile(
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
                    onPressed: () =>
                        ref.removeExerciseFromWorkout(workoutId, cat.id),
                  ),
                )),
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

  void _showAddExercisesSheet(BuildContext context, WidgetRef ref,
      List<ExerciseCategory> current) {
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

class _AddExercisesSheet extends ConsumerWidget {
  final int workoutId;
  final List<ExerciseCategory> current;
  const _AddExercisesSheet(
      {required this.workoutId, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(categoriesProvider).value ?? [];
    final currentIds = current.map((c) => c.id).toSet();

    void showCreateDialog() {
      final db   = ref.read(dbProvider);
      final ctrl = TextEditingController();

      Future<void> doCreate(BuildContext dialogCtx) async {
        final name = ctrl.text.trim();
        if (name.isEmpty) return;
        final catId = await db.insertCategory(name);
        await db.addExerciseToWorkout(workoutId, catId);
        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
      }

      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('New Exercise'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Exercise name'),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => doCreate(dialogCtx),
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
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Add exercises to workout',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: ctrl,
              itemCount: all.length + 1,
              itemBuilder: (_, i) {
                if (i == all.length) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: TextButton.icon(
                      onPressed: showCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('New exercise…'),
                    ),
                  );
                }
                final cat = all[i];
                final inWorkout = currentIds.contains(cat.id);
                return CheckboxListTile(
                  value: inWorkout,
                  title: Text(cat.name),
                  subtitle: cat.groupName != null
                      ? Text(cat.groupName!,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  onChanged: (_) {
                    if (inWorkout) {
                      ref.removeExerciseFromWorkout(workoutId, cat.id);
                    } else {
                      ref.addExerciseToWorkout(workoutId, cat.id);
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

enum _Action { rename, delete }
