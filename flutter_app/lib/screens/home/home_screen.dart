import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../providers/backup_provider.dart';
import '../../utils/format_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected  = ref.watch(selectedDateProvider);
    final dateStr   = dateStrFrom(selected);
    final setsAsync = ref.watch(setsForDayProvider(dateStr));
    final cats      = ref.watch(categoriesProvider).value ?? [];
    final woDates   = ref.watch(workoutDatesProvider).value ?? [];
    final plannedWorkouts =
        ref.watch(plannedWorkoutsForDateProvider(dateStr)).value ?? [];

    // Unstarted planned exercises for the FAB quick-pick
    final loggedCatIds = (setsAsync.value ?? []).map((s) => s.categoryId).toSet();
    final loggedSetCount = setsAsync.value?.length ?? 0;
    final unstartedExercises = <(String, ExerciseCategory)>[];
    for (final (workout, exercises) in plannedWorkouts) {
      for (final cat in exercises) {
        if (!loggedCatIds.contains(cat.id)) {
          unstartedExercises.add((workout.name, cat));
        }
      }
    }

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _DayNavBar(
              selected: selected,
              onPrev: () => ref.read(selectedDateProvider.notifier).state =
                  selected.subtract(const Duration(days: 1)),
              onNext: () => ref.read(selectedDateProvider.notifier).state =
                  selected.add(const Duration(days: 1)),
              onCalendar: () => _openCalendar(context, ref, selected, woDates),
              onInspirations: () => context.push('/inspirations'),
              onSaveAsWorkout: loggedCatIds.isEmpty
                  ? null
                  : () => _saveDayAsWorkout(context, ref, selected, dateStr,
                      loggedCatIds.length, loggedSetCount),
            ),
          ),

          // ── Day meta row (body weight + session note) ──────────────────
          _DayMetaSection(dateStr: dateStr),
          const Divider(height: 1, thickness: 0.5),

          if (woDates.isNotEmpty) const _BackupNudge(),

          Expanded(
            child: setsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (sets) {
                final grouped = <int, List<WorkoutSet>>{};
                for (final s in sets) {
                  grouped.putIfAbsent(s.categoryId, () => []).add(s);
                }

                // Category IDs accounted for by planned workouts
                final plannedCatIds = plannedWorkouts
                    .expand((w) => w.$2.map((e) => e.id))
                    .toSet();

                // Logged sets whose exercise is not in any planned workout
                final extraIds = grouped.keys
                    .where((id) => !plannedCatIds.contains(id))
                    .toList();

                if (plannedWorkouts.isEmpty && grouped.isEmpty) {
                  return _EmptyState(
                      onStart: () => context.go('/exercises'));
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  children: [
                    // ── Planned workout sections ─────────────────────────
                    for (final (workout, exercises) in plannedWorkouts) ...[
                      _SectionHeader(
                        name: workout.name,
                        onStart: exercises.isEmpty
                            ? null
                            : () => context.push(
                                '/workout-session/${workout.id}/$dateStr'),
                      ),
                      const SizedBox(height: 4),
                      ...exercises.map((cat) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _DayExerciseCard(
                              name: cat.name,
                              sets: grouped[cat.id] ?? [],
                              onTap: () => context
                                  .push('/exercise/${cat.id}/$dateStr'),
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],

                    // ── Logged sets not in any planned workout ───────────
                    if (extraIds.isNotEmpty) ...[
                      if (plannedWorkouts.isNotEmpty)
                        const _SectionHeader(name: 'Other'),
                      if (plannedWorkouts.isNotEmpty)
                        const SizedBox(height: 4),
                      ...extraIds.map((catId) {
                        final name = cats
                            .firstWhere((c) => c.id == catId,
                                orElse: () =>
                                    ExerciseCategory(id: catId, name: 'Unknown', exerciseType: 0))
                            .name;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _DayExerciseCard(
                            name: name,
                            sets: grouped[catId]!,
                            onTap: () =>
                                context.push('/exercise/$catId/$dateStr'),
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (unstartedExercises.isEmpty) {
            context.go('/exercises');
          } else {
            _showQuickPick(context, dateStr, unstartedExercises);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Turns the exercises logged on [dateStr] into a reusable workout, using
  /// the logged set/rep counts as targets.
  Future<void> _saveDayAsWorkout(
    BuildContext context,
    WidgetRef ref,
    DateTime selected,
    String dateStr,
    int exerciseCount,
    int setCount,
  ) async {
    final defaultName = await ref
        .uniqueWorkoutName('${DateFormat('EEE').format(selected)} session');
    if (!context.mounted) return;

    final name = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (_) => _SaveDayDialog(
        initialName:   defaultName,
        exerciseCount: exerciseCount,
        setCount:      setCount,
      ),
    );
    if (name == null || !context.mounted) return;

    final id = await ref.createWorkoutFromDay(dateStr, name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Saved "$name"'),
      action: SnackBarAction(
        label: 'OPEN',
        onPressed: () => context.push('/workouts/$id'),
      ),
    ));
  }

  void _showQuickPick(
    BuildContext context,
    String dateStr,
    List<(String, ExerciseCategory)> exercises,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Log exercise',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/exercises');
                    },
                    child: const Text('All exercises'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...exercises.map((e) => ListTile(
                  leading: const Icon(Icons.fitness_center, size: 20),
                  title: Text(e.$2.name),
                  subtitle: Text(e.$1,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4))),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/exercise/${e.$2.id}/$dateStr');
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selected,
    List<String> woDates,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CalendarSheet(
        selected:     selected,
        workoutDates: woDates.toSet(),
        onSelected: (date) {
          ref.read(selectedDateProvider.notifier).state = date;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Day meta section (body weight + session note) ───────────────────────────

class _DayMetaSection extends ConsumerWidget {
  final String dateStr;
  const _DayMetaSection({required this.dateStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyWeight = ref.watch(bodyWeightForDateProvider(dateStr)).value;
    final dayNote    = ref.watch(dayNoteProvider(dateStr)).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _MetaChip(
            icon: Icons.monitor_weight_outlined,
            label: bodyWeight != null
                ? '${bodyWeight.kg.toStringAsFixed(1)} kg'
                : 'Log weight',
            active: bodyWeight != null,
            onTap: () => _editWeight(context, ref, bodyWeight?.kg),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetaChip(
              icon: Icons.notes_outlined,
              label: (dayNote?.note.isNotEmpty == true)
                  ? dayNote!.note
                  : 'Add note',
              active: dayNote != null && dayNote.note.isNotEmpty,
              onTap: () => _editNote(context, ref, dayNote?.note),
            ),
          ),
        ],
      ),
    );
  }

  void _editWeight(BuildContext context, WidgetRef ref, double? current) {
    showDialog(
      context: context,
      builder: (_) => _WeightDialog(
        initial: current,
        onSave:  (kg) => ref.saveBodyWeight(dateStr, kg),
        onClear: current != null ? () => ref.deleteBodyWeight(dateStr) : null,
      ),
    );
  }

  void _editNote(BuildContext context, WidgetRef ref, String? current) {
    showDialog(
      context: context,
      builder: (_) => _NoteDialog(
        initial: current,
        onSave:  (note) {
          if (note.isEmpty) {
            ref.deleteDayNote(dateStr);
          } else {
            ref.saveDayNote(dateStr, note);
          }
        },
      ),
    );
  }
}

/// Nothing here syncs anywhere, so this is the one reminder the app gives:
/// a quiet line when the last export is a month behind, dismissible for a
/// week at a time.
class _BackupNudge extends ConsumerWidget {
  const _BackupNudge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backupProvider);
    if (!status.needsReminder(DateTime.now())) return const SizedBox.shrink();

    final days = status.daysSinceBackup(DateTime.now());
    final color = Theme.of(context).colorScheme.error;
    return Material(
      color: color.withValues(alpha: 0.10),
      child: InkWell(
        onTap: () => context.push('/settings'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  days == null
                      ? 'Your training history has never been backed up.'
                      : 'Last backup was $days days ago.',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/settings'),
                child: const Text('BACK UP', style: TextStyle(fontSize: 12)),
              ),
              IconButton(
                tooltip: 'Remind me later',
                onPressed: () => ref.read(backupProvider.notifier).snoozeReminder(),
                icon: Icon(Icons.close,
                    size: 16, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  final VoidCallback onTap;
  const _MetaChip(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: 0.10)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active
                  ? primary.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active ? primary : Colors.white.withValues(alpha: 0.35)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: active
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.35)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weight entry dialog ─────────────────────────────────────────────────────

class _WeightDialog extends StatefulWidget {
  final double? initial;
  final Future<void> Function(double) onSave;
  final VoidCallback? onClear;
  const _WeightDialog({this.initial, required this.onSave, this.onClear});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initial != null
          ? widget.initial!.toStringAsFixed(1)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Body weight'),
        content: TextField(
          controller: _ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'kg'),
          onSubmitted: (_) => _save(),
        ),
        actions: [
          if (widget.onClear != null)
            TextButton(
              onPressed: () {
                widget.onClear!();
                Navigator.pop(context);
              },
              child: Text('Clear',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      );

  void _save() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', '.'));
    if (v != null && v > 0) {
      widget.onSave(v);
      Navigator.pop(context);
    }
  }
}

// ── Session note dialog ─────────────────────────────────────────────────────

class _NoteDialog extends StatefulWidget {
  final String? initial;
  final void Function(String) onSave;
  const _NoteDialog({this.initial, required this.onSave});

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Session note'),
        content: TextField(
          controller: _ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'How did the session go?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widget.onSave(_ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
}

// ── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String name;
  final VoidCallback? onStart;
  const _SectionHeader({required this.name, this.onStart});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
          if (onStart != null)
            TextButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('START'),
              style: TextButton.styleFrom(
                foregroundColor: primary,
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Day nav bar ─────────────────────────────────────────────────────────────

class _DayNavBar extends StatelessWidget {
  final DateTime selected;
  final VoidCallback onPrev, onNext, onCalendar, onInspirations;
  /// Null when nothing is logged on this day — the action is then hidden.
  final VoidCallback? onSaveAsWorkout;
  const _DayNavBar(
      {required this.selected,
      required this.onPrev,
      required this.onNext,
      required this.onCalendar,
      required this.onInspirations,
      this.onSaveAsWorkout});

  String get _label {
    final now = DateTime.now();
    if (isSameDay(selected, now)) return 'TODAY';
    if (isSameDay(selected, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
    if (isSameDay(selected, now.add(const Duration(days: 1)))) return 'TOMORROW';
    return DateFormat('EEE, MMM d').format(selected).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: GestureDetector(
              onTap: onCalendar,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_label,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(width: 6),
                  Icon(Icons.calendar_month,
                      size: 17,
                      color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          IconButton(
            onPressed: onInspirations,
            tooltip: 'Inspirations',
            icon: Icon(Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary),
          ),
          if (onSaveAsWorkout != null)
            PopupMenuButton<void>(
              icon: Icon(Icons.more_vert,
                  color: Colors.white.withValues(alpha: 0.5)),
              tooltip: 'More',
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: onSaveAsWorkout,
                  child: const Text('Save day as workout…'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Save-day-as-workout dialog ──────────────────────────────────────────────

class _SaveDayDialog extends StatefulWidget {
  final String initialName;
  final int exerciseCount;
  final int setCount;
  const _SaveDayDialog(
      {required this.initialName,
      required this.exerciseCount,
      required this.setCount});

  @override
  State<_SaveDayDialog> createState() => _SaveDayDialogState();
}

class _SaveDayDialogState extends State<_SaveDayDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName)
      ..selection = TextSelection(
          baseOffset: 0, extentOffset: widget.initialName.length);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  static String _plural(int n, String word) =>
      '$n $word${n == 1 ? '' : 's'}';

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Save day as workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_plural(widget.exerciseCount, 'exercise')} '
              '(${_plural(widget.setCount, 'set')}) from this day will become '
              'a reusable workout, with the logged sets and reps as targets.',
              style: TextStyle(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Workout name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      );
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 72, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text('Nothing planned here.',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.35))),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add),
              label: const Text('Log an exercise'),
            ),
          ],
        ),
      );
}

// ── Exercise summary card ───────────────────────────────────────────────────

class _DayExerciseCard extends StatelessWidget {
  final String name;
  final List<WorkoutSet> sets;
  final VoidCallback onTap;
  const _DayExerciseCard(
      {required this.name, required this.sets, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    sets.isEmpty
                        ? Text('not started',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 13))
                        : Text(
                            '${sets.length} set${sets.length != 1 ? "s" : ""}',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontSize: 13),
                          ),
                  ],
                ),
                if (sets.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...sets.asMap().entries.map((e) => Text(
                        '  Set ${e.key + 1}:  ${formatSet(weightKg: e.value.weightKg, reps: e.value.reps, timeSecs: e.value.timeSecs)}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.55)),
                      )),
                ],
              ],
            ),
          ),
        ),
      );
}

// ── Calendar bottom sheet ───────────────────────────────────────────────────

class _CalendarSheet extends StatefulWidget {
  final DateTime selected;
  final Set<String> workoutDates;
  final ValueChanged<DateTime> onSelected;
  const _CalendarSheet(
      {required this.selected,
      required this.workoutDates,
      required this.onSelected});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focused;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _focused  = widget.selected;
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay:  DateTime(2020),
          lastDay:   DateTime(2030),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            final s = dateStrFrom(day);
            return widget.workoutDates.contains(s) ? [s] : [];
          },
          onDaySelected: (sel, foc) {
            setState(() {
              _selected = sel;
              _focused  = foc;
            });
            widget.onSelected(sel);
          },
          onPageChanged: (foc) => setState(() => _focused = foc),
        ),
      );
}
