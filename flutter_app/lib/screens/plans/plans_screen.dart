import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/pick_text_file.dart';
import '../../utils/undo_snackbar.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(allWorkoutsProvider).value ?? [];
    final plans    = ref.watch(allPlansProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        children: [
          // ── Workouts section ─────────────────���─────────────────────────
          _SectionHeader(
            title: 'WORKOUTS',
            onAdd: _showCreateWorkoutDialog,
          ),
          if (workouts.isEmpty)
            _EmptyHint('No workouts yet.')
          else
            ...workouts.map((w) => _ItemTile(
                  title: w.name,
                  onTap: () => context.push('/workouts/${w.id}'),
                  onStart: () => context.push(
                      '/workout-session/${w.id}/${dateStrFrom(DateTime.now())}'),
                  onRename: () => _showRenameDialog(
                      context, ref, w.name,
                      (name) => ref.renameWorkout(w.id, name)),
                  onDuplicate: () => _duplicateWorkout(w.id),
                  onDelete: () => _showDeleteDialog(
                      context, ref, '"${w.name}"',
                      'All exercises in this workout will be removed.',
                      () async {
                    final deleted = await ref.deleteWorkout(w.id);
                    return deleted == null
                        ? null
                        : (
                            message: 'Deleted "${w.name}"',
                            undo: () => ref.restoreWorkout(deleted)
                          );
                  }),
                )),

          const SizedBox(height: 24),

          // ── Training plans section ───────────────────────────────��─────
          _SectionHeader(
            title: 'TRAINING PLANS',
            onAdd: () => _showCreateDialog(
              context, ref, 'New Plan', ref.insertPlan),
            onImport: _importPlan,
          ),
          if (plans.isEmpty)
            _EmptyHint('No plans yet.')
          else
            ...plans.map((p) => _ItemTile(
                  title: p.name,
                  onTap: () => context.push('/plans/${p.id}'),
                  onRename: () => _showRenameDialog(
                      context, ref, p.name,
                      (name) => ref.renamePlan(p.id, name)),
                  onDelete: () => _showDeleteDialog(
                      context, ref, '"${p.name}"',
                      'All workout assignments in this plan will be removed.',
                      () async {
                    final deleted = await ref.deletePlan(p.id);
                    return deleted == null
                        ? null
                        : (
                            message: 'Deleted "${p.name}"',
                            undo: () => ref.restorePlan(deleted)
                          );
                  }),
                )),
        ],
      ),
    );
  }

  Future<void> _showCreateWorkoutDialog() async {
    final result = await showDialog<(String, int?)>(
      context: context,
      useRootNavigator: false,
      builder: (_) =>
          _NewWorkoutDialog(sources: ref.read(allWorkoutsProvider).value ?? []),
    );
    if (result == null) return;

    final (name, copyFromId) = result;
    final id = copyFromId == null
        ? await ref.insertWorkout(name)
        : await ref.duplicateWorkout(copyFromId, newName: name);
    if (mounted) context.push('/workouts/$id');
  }

  Future<void> _duplicateWorkout(int workoutId) async {
    final id = await ref.duplicateWorkout(workoutId);
    if (mounted) context.push('/workouts/$id');
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref, String title,
      Future<int> Function(String) onCreate) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _create(context, ctrl.text, onCreate),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _create(context, ctrl.text, onCreate),
              child: const Text('Create')),
        ],
      ),
    );
  }

  void _create(BuildContext context, String name,
      Future<int> Function(String) onCreate) {
    if (name.trim().isEmpty) return;
    onCreate(name.trim());
    Navigator.pop(context);
  }

  Future<void> _importPlan() async {
    final messenger = ScaffoldMessenger.of(context);

    final String? jsonStr;
    try {
      jsonStr = await pickTextFile(extension: 'json');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not read file: $e')));
      return;
    }
    if (jsonStr == null || !mounted) return;

    // If a plan with this name already exists, confirm before clobbering
    // its existing schedule.
    String? planName;
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      planName = (data['plan'] as Map<String, dynamic>?)?['name'] as String?;
    } catch (_) {}
    if (planName != null && mounted) {
      final existing = ref.read(allPlansProvider).value ?? [];
      final clash = existing.any((p) => p.name == planName);
      if (clash) {
        final ok = await showDialog<bool>(
          context: context,
          useRootNavigator: false,
          builder: (_) => AlertDialog(
            title: Text('Replace "$planName"?'),
            content: const Text(
                'A plan with this name already exists. Importing will replace '
                'its current schedule. Workouts in the library are kept as-is; '
                'any workouts not yet in the library will be added.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace')),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
    }

    try {
      final planId = await ref.read(dbProvider).importPlanFromJson(jsonStr);
      messenger.showSnackBar(const SnackBar(content: Text('Plan imported')));
      if (mounted) context.push('/plans/$planId');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, String current,
      void Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _save(context, ctrl.text, onSave),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _save(context, ctrl.text, onSave),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _save(
      BuildContext context, String name, void Function(String) onSave) {
    if (name.trim().isEmpty) return;
    onSave(name.trim());
    Navigator.pop(context);
  }

  /// [onDelete] performs the deletion and returns what to say and how to take
  /// it back, or null if there was nothing to delete.
  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    String detail,
    Future<({String message, VoidCallback undo})?> Function() onDelete,
  ) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: Text('Delete $label?'),
        content: Text(detail),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final result = await onDelete();
              navigator.pop();
              if (result == null) return;
              showUndoSnackBar(messenger,
                  message: result.message, onUndo: result.undo);
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

// ── Section header with + button ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final VoidCallback? onImport;
  const _SectionHeader({required this.title, required this.onAdd, this.onImport});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 2),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (onImport != null)
              IconButton(
                icon: const Icon(Icons.file_upload_outlined, size: 20),
                onPressed: onImport,
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Import from JSON',
              ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: onAdd,
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Add',
            ),
          ],
        ),
      );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Text(text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35))),
      );
}

class _ItemTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  /// Workouts can be trained straight from the list; plans are schedules and
  /// have nothing to start.
  final VoidCallback? onStart;
  const _ItemTile(
      {required this.title,
      required this.onTap,
      required this.onRename,
      required this.onDelete,
      this.onDuplicate,
      this.onStart});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onStart != null)
              IconButton(
                tooltip: 'Start workout',
                onPressed: onStart,
                icon: Icon(Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary),
              ),
            PopupMenuButton<_Action>(
              icon: Icon(Icons.more_vert,
                  color: Colors.white.withValues(alpha: 0.35), size: 20),
              onSelected: (a) => switch (a) {
                _Action.start     => onStart?.call(),
                _Action.rename    => onRename(),
                _Action.duplicate => onDuplicate?.call(),
                _Action.delete    => onDelete(),
              },
              itemBuilder: (_) => [
                if (onStart != null)
                  const PopupMenuItem(
                      value: _Action.start, child: Text('Start workout')),
                const PopupMenuItem(
                    value: _Action.rename, child: Text('Rename')),
                if (onDuplicate != null)
                  const PopupMenuItem(
                      value: _Action.duplicate, child: Text('Duplicate')),
                const PopupMenuItem(
                    value: _Action.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        onTap: onTap,
      );
}

enum _Action { start, rename, duplicate, delete }

// ── New workout dialog (optionally pre-filled from an existing workout) ──────

class _NewWorkoutDialog extends StatefulWidget {
  final List<Workout> sources;
  const _NewWorkoutDialog({required this.sources});

  @override
  State<_NewWorkoutDialog> createState() => _NewWorkoutDialogState();
}

class _NewWorkoutDialogState extends State<_NewWorkoutDialog> {
  final _ctrl = TextEditingController();
  int? _copyFromId;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Pops with (name, copyFromId) — copyFromId null means an empty workout.
  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name, _copyFromId));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('New Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _submit(),
            ),
            if (widget.sources.isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                initialValue: _copyFromId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Start from'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Empty workout')),
                  ...widget.sources.map((w) => DropdownMenuItem(
                        value: w.id,
                        child:
                            Text(w.name, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => setState(() => _copyFromId = v),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(onPressed: _submit, child: const Text('Create')),
        ],
      );
}
