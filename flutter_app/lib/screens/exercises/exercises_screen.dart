import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/share_file.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool   _importing = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCats = ref.watch(categoriesProvider);

    // Show spinner while the database is still initialising (common on web/WASM).
    if (asyncCats.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show actionable error if the database failed to open.
    if (asyncCats.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Database failed to load.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you are on the web, try a hard-refresh\n'
                  '(Ctrl+Shift+R / Cmd+Shift+R) or clear the\n'
                  'site data in your browser settings.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '${asyncCats.error}',
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final all     = asyncCats.value ?? [];
    final visible = _query.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    // Grouped: null group at the end under "Other"
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

    // Flatten into a mixed list: String = section header, ExerciseCategory = tile
    final items = <Object>[];
    for (final group in sortedGroups) {
      items.add(group ?? 'Other');
      items.addAll(grouped[group]!);
    }

    // Distinct group names for autocomplete in the add dialog
    final groups = sortedGroups
        .whereType<String>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Exercises',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<_DataAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              if (action == _DataAction.exportBackup)   _exportBackup();
              if (action == _DataAction.importBackup)   _importBackup(context);
              if (action == _DataAction.importFitNotes) context.push('/import');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: _DataAction.exportBackup,
                  child: ListTile(
                      leading: Icon(Icons.download), title: Text('Export backup'))),
              PopupMenuItem(
                  value: _DataAction.importBackup,
                  child: ListTile(
                      leading: Icon(Icons.upload), title: Text('Import backup'))),
              PopupMenuDivider(),
              PopupMenuItem(
                  value: _DataAction.importFitNotes,
                  child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('Import FitNotes CSV'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, groups),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          if (_importing)
            const LinearProgressIndicator(),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      all.isEmpty
                          ? 'No exercises yet.\nTap + to add one.'
                          : 'No results for "$_query"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha:0.35)),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      if (item is String) {
                        return _GroupHeader(name: item);
                      }
                      final cat = item as ExerciseCategory;
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () => _pickImage(context, cat.id, cat.imageData),
                          child: _ImageAvatar(data: cat.imageData),
                        ),
                        title: Text(cat.name),
                        trailing: PopupMenuButton<_ExAction>(
                          icon: Icon(Icons.more_vert,
                              color: Colors.white.withValues(alpha:0.35),
                              size: 20),
                          onSelected: (action) {
                            if (action == _ExAction.rename) {
                              _showRenameDialog(context, cat.id, cat.name);
                            } else if (action == _ExAction.changeCategory) {
                              _showChangeCategoryDialog(
                                  context, cat.id, cat.groupName, groups);
                            } else if (action == _ExAction.addToWorkout) {
                              _showAddToWorkoutSheet(context, cat.id, cat.name);
                            } else {
                              _showDeleteDialog(context, cat.id, cat.name);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: _ExAction.rename,
                                child: Text('Rename')),
                            PopupMenuItem(
                                value: _ExAction.changeCategory,
                                child: Text('Change category')),
                            PopupMenuItem(
                                value: _ExAction.addToWorkout,
                                child: Text('Add to workout')),
                            PopupMenuItem(
                                value: _ExAction.delete,
                                child: Text('Delete')),
                          ],
                        ),
                        onTap: () {
                          final today = dateStrFrom(DateTime.now());
                          context.push('/exercise/${cat.id}/$today');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Backup export / import ────────────────────────────────────────────────

  Future<void> _exportBackup() async {
    try {
      final json     = await ref.read(dbProvider).exportToJson();
      final filename =
          'training_logger_${dateStrFrom(DateTime.now())}.json';
      await shareJsonFile(json, filename);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    // Capture before any await
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb,
      withReadStream: false,
    );
    if (result == null || !mounted) return;

    setState(() => _importing = true);
    try {
      final String jsonStr;
      if (kIsWeb) {
        jsonStr = utf8.decode(result.files.single.bytes!);
      } else {
        jsonStr = await io.File(result.files.single.path!).readAsString();
      }
      final count = await ref.read(dbProvider).importFromJson(jsonStr);
      messenger.showSnackBar(SnackBar(content: Text('Imported $count sets')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _pickImage(
      BuildContext context, int categoryId, Uint8List? current) async {
    final action = await showModalBottomSheet<_ImageAction>(
      context: context,
      useRootNavigator: false,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, _ImageAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, _ImageAction.camera),
            ),
            if (current != null)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Remove photo',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
                onTap: () => Navigator.pop(context, _ImageAction.remove),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    if (action == _ImageAction.remove) {
      await ref.saveCategoryImage(categoryId, null);
      return;
    }

    final source = action == _ImageAction.gallery
        ? ImageSource.gallery
        : ImageSource.camera;
    final xFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    await ref.saveCategoryImage(categoryId, bytes);
  }

  void _showAddDialog(BuildContext context, List<String> existingGroups) {
    final nameCtrl  = TextEditingController();
    final groupCtrl = TextEditingController();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('New Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Exercise name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _add(context, nameCtrl.text, groupCtrl.text),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (v) => existingGroups.where((g) =>
                  g.toLowerCase().contains(v.text.toLowerCase())),
              onSelected: (g) => groupCtrl.text = g,
              fieldViewBuilder: (_, ctrl, focus, __) {
                groupCtrl.addListener(() {}); // keep in sync
                return TextField(
                  controller: ctrl,
                  focusNode: focus,
                  decoration: const InputDecoration(
                      labelText: 'Category (optional)',
                      hintText: 'e.g. Fingers, Back…'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => groupCtrl.text = v,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  _add(context, nameCtrl.text, groupCtrl.text),
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _add(BuildContext context, String name, String group) {
    if (name.trim().isEmpty) return;
    final g = group.trim().isEmpty ? null : group.trim();
    ref.addCategory(name.trim(), groupName: g);
    Navigator.pop(context);
  }

  void _showChangeCategoryDialog(BuildContext context, int id,
      String? currentGroup, List<String> existingGroups) {
    final ctrl = TextEditingController(text: currentGroup ?? '');
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Change Category'),
        content: Autocomplete<String>(
          initialValue: TextEditingValue(text: currentGroup ?? ''),
          optionsBuilder: (v) => existingGroups.where((g) =>
              g.toLowerCase().contains(v.text.toLowerCase())),
          onSelected: (g) => ctrl.text = g,
          fieldViewBuilder: (_, autoCtrl, focus, __) {
            // Keep ctrl in sync with the autocomplete's internal controller
            autoCtrl.addListener(() => ctrl.text = autoCtrl.text);
            return TextField(
              controller: autoCtrl,
              focusNode: focus,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Fingers, Back… (leave empty to remove)'),
              textCapitalization: TextCapitalization.words,
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _changeCategory(context, id, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _changeCategory(BuildContext context, int id, String group) {
    final g = group.trim().isEmpty ? null : group.trim();
    ref.updateCategoryGroup(id, g);
    Navigator.pop(context);
  }

  void _showRenameDialog(BuildContext context, int id, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('Rename Exercise'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Exercise name'),
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
    ref.renameCategory(id, name.trim());
    Navigator.pop(context);
  }

  void _showAddToWorkoutSheet(BuildContext context, int categoryId, String exerciseName) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddToWorkoutSheet(
        categoryId: categoryId,
        exerciseName: exerciseName,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text(
            'All logged sets for this exercise will remain in history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.removeCategory(id);
              Navigator.pop(context);
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

// ── Section header ────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String name;
  const _GroupHeader({required this.name});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

// ── Image avatar ──────────────────────────────────────────────────────────────

// ── Add-to-workout sheet ──────────────────────────────────────────────────────

class _AddToWorkoutSheet extends ConsumerWidget {
  final int    categoryId;
  final String exerciseName;
  const _AddToWorkoutSheet(
      {required this.categoryId, required this.exerciseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts        = ref.watch(allWorkoutsProvider).value ?? [];
    final workoutsWithThis =
        ref.watch(workoutsForExerciseProvider(categoryId)).value ?? [];
    final inWorkoutIds    = workoutsWithThis.map((w) => w.id).toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add "$exerciseName" to workout',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          if (workouts.isEmpty)
            Text('No workouts yet.',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.4)))
          else
            ...workouts.map((workout) {
              final inWorkout = inWorkoutIds.contains(workout.id);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: inWorkout,
                title: Text(workout.name),
                onChanged: (_) {
                  if (inWorkout) {
                    ref.removeExerciseFromWorkout(workout.id, categoryId);
                  } else {
                    ref.addExerciseToWorkout(workout.id, categoryId);
                  }
                },
              );
            }),
          const Divider(height: 24),
          TextButton.icon(
            onPressed: () => _createAndAdd(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New workout…'),
          ),
        ],
      ),
    );
  }

  void _createAndAdd(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: const Text('New Workout'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Workout name'),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _doCreate(context, ref, ctrl.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => _doCreate(context, ref, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
  }

  Future<void> _doCreate(
      BuildContext context, WidgetRef ref, String name) async {
    if (name.trim().isEmpty) return;
    final workoutId = await ref.insertWorkout(name.trim());
    await ref.addExerciseToWorkout(workoutId, categoryId);
    if (context.mounted) Navigator.pop(context);
  }
}

enum _DataAction { exportBackup, importBackup, importFitNotes }

enum _ExAction { rename, changeCategory, addToWorkout, delete }

enum _ImageAction { gallery, camera, remove }

class _ImageAvatar extends StatelessWidget {
  final Uint8List? data;
  const _ImageAvatar({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 46,
        height: 46,
        child: data != null
            ? Image.memory(data!, fit: BoxFit.cover)
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.fitness_center,
                    size: 22,
                    color: Colors.white.withValues(alpha:0.3)),
              ),
      ),
    );
  }
}
