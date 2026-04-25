import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final int workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  late final TextEditingController _notesCtrl;
  late final FocusNode _notesFocus;
  bool _notesInited = false;
  bool _autoOpenedSheet = false;
  String _savedNotes = '';

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _notesFocus = FocusNode()..addListener(_onNotesFocusChange);
  }

  @override
  void dispose() {
    _notesFocus.removeListener(_onNotesFocusChange);
    // Persist any unsaved edits before disposing.
    _flushNotes();
    _notesFocus.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onNotesFocusChange() {
    if (!_notesFocus.hasFocus) _flushNotes();
  }

  void _flushNotes() {
    if (!_notesInited) return;
    final text = _notesCtrl.text;
    if (text == _savedNotes) return;
    _savedNotes = text;
    ref.read(dbProvider).updateWorkoutNotes(widget.workoutId, text);
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(allWorkoutsProvider).value
        ?.firstWhere((w) => w.id == widget.workoutId,
            orElse: () => Workout(id: widget.workoutId, name: '', notes: ''));
    final exercises =
        ref.watch(workoutExercisesProvider(widget.workoutId)).value ?? [];

    // Sync notes controller once when data first arrives. Skip if the user
    // is already typing — don't clobber in-progress edits.
    if (!_notesInited && workout != null && !_notesFocus.hasFocus) {
      _notesInited = true;
      _savedNotes = workout.notes;
      _notesCtrl.text = workout.notes;
    }

    // Auto-open exercise picker for empty workouts (e.g. just created)
    if (!_autoOpenedSheet && exercises.isEmpty && workout != null) {
      _autoOpenedSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddExercisesSheet(context, exercises);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workout?.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (workout != null)
            PopupMenuButton<_Action>(
              icon: const Icon(Icons.more_vert),
              onSelected: (a) => a == _Action.rename
                  ? _showRenameDialog(context, workout.id, workout.name)
                  : _showDeleteDialog(context, workout.id, workout.name),
              itemBuilder: (_) => const [
                PopupMenuItem(value: _Action.rename, child: Text('Rename')),
                PopupMenuItem(
                    value: _Action.delete, child: Text('Delete workout')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Notes field ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _notesCtrl,
              focusNode: _notesFocus,
              maxLines: null,
              minLines: 1,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8)),
              decoration: InputDecoration(
                hintText: 'Add workout notes...',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // ── Exercise list (reorderable) ───────────────────────────────
          Expanded(
            child: exercises.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('No exercises yet.',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4))),
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                    itemCount: exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final ids =
                          exercises.map((e) => e.$1).toList();
                      final moved = ids.removeAt(oldIndex);
                      ids.insert(newIndex, moved);
                      ref.reorderWorkoutExercises(
                          widget.workoutId, ids);
                    },
                    itemBuilder: (_, i) {
                      final (weId, cat, targetSets, targetReps) = exercises[i];
                      final targetLabel =
                          _formatTarget(targetSets, targetReps);
                      final hasTarget =
                          targetSets != null || targetReps != null;
                      return ListTile(
                        key: ValueKey(weId),
                        leading: ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle,
                              color: Colors.white38),
                        ),
                        title: Text(cat.name),
                        subtitle: cat.groupName != null
                            ? Text(cat.groupName!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white
                                        .withValues(alpha: 0.45)))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _showEditTargetDialog(
                                  context, weId, targetSets, targetReps),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  targetLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasTarget
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Colors.white
                                            .withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20),
                              color: Colors.white54,
                              onPressed: () => ref
                                  .removeExerciseFromWorkout(weId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // ── Add exercises button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showAddExercisesSheet(context, exercises),
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

  static String _formatTarget(int? sets, int? reps) {
    if (sets != null && reps != null) return '$sets\u00d7$reps';
    if (sets != null) return '$sets sets';
    if (reps != null) return '\u00d7$reps';
    return 'set target';
  }

  void _showEditTargetDialog(BuildContext context, int weId,
      int? currentSets, int? currentReps) {
    final setsCtrl = TextEditingController(
        text: currentSets?.toString() ?? '');
    final repsCtrl = TextEditingController(
        text: currentReps?.toString() ?? '');

    void save(BuildContext dialogCtx) {
      final sets = setsCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(setsCtrl.text.trim());
      final reps = repsCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(repsCtrl.text.trim());
      ref.updateWorkoutTarget(weId, sets, reps);
      Navigator.pop(dialogCtx);
    }

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Set target'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  hintText: '\u2014',
                ),
                onSubmitted: (_) => save(dialogCtx),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('\u00d7',
                  style: TextStyle(fontSize: 20, color: Colors.white54)),
            ),
            Expanded(
              child: TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  hintText: '\u2014',
                ),
                onSubmitted: (_) => save(dialogCtx),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => save(dialogCtx),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showAddExercisesSheet(BuildContext context,
      List<(int, ExerciseCategory, int?, int?)> exercises) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddExercisesSheet(
        workoutId: widget.workoutId,
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, int id, String current) {
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
          onSubmitted: (_) => _rename(context, id, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _rename(context, id, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _rename(BuildContext context, int id, String name) {
    if (name.trim().isEmpty) return;
    ref.renameWorkout(id, name.trim());
    Navigator.pop(context);
  }

  void _showDeleteDialog(
      BuildContext context, int id, String name) {
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
  const _AddExercisesSheet({required this.workoutId});

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
    final currentExercises = ref.watch(workoutExercisesProvider(widget.workoutId)).value ?? [];
    final countById = <int, int>{};
    for (final e in currentExercises) {
      countById[e.$2.id] = (countById[e.$2.id] ?? 0) + 1;
    }

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
                      label: const Text('New exercise\u2026'),
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

                final cat   = item as ExerciseCategory;
                final count = countById[cat.id] ?? 0;
                return ListTile(
                  dense: true,
                  title: Text(cat.name),
                  trailing: count > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\u00d7$count',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    ref.addExerciseToWorkout(widget.workoutId, cat.id);
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
                return TextField(
                  controller: autoCtrl,
                  focusNode: focus,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'e.g. Bouldering, Core\u2026',
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
