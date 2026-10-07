import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';
import '../../utils/periodization.dart';
import '../../utils/undo_snackbar.dart';

/// The phases of a plan: each one's length, deload rule, rotation of sessions
/// and RPE overrides. A plan with phases runs them in order, a pass through
/// the rotation at a time (shown as a "week"), instead of by weekday.
class PhasesSection extends ConsumerWidget {
  final int planId;

  /// Opens a workout picker that adds the chosen workout to [phaseId]'s
  /// rotation.
  final void Function(int phaseId) onAddSession;

  const PhasesSection(
      {super.key, required this.planId, required this.onAddSession});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = ref.watch(planPhasesProvider(planId)).value ?? [];
    final sessions = ref.watch(planSessionsProvider(planId)).value ?? [];
    final workouts = ref.watch(allWorkoutsProvider).value ?? [];
    final active = ref.watch(activePlanProvider).value;
    final running = active?.plan.id == planId ? active!.state : null;
    final primary = Theme.of(context).colorScheme.primary;

    String workoutName(int id) =>
        workouts.where((w) => w.id == id).firstOrNull?.name ?? '?';

    final currentIndex = running?.phase == null
        ? (running?.planComplete ?? false ? phases.length : -1)
        : phases.indexWhere((p) => p.id == running!.phase!.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('PHASES',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: primary)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _addPhase(context, ref),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add phase'),
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ],
        ),
        if (phases.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Add a phase to run this plan in blocks of weeks, each with '
              'its own rotation of sessions and target RPEs, instead of by '
              'weekday.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            ),
          )
        else ...[
          if (running != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_progressLine(running),
                      style: TextStyle(
                          fontSize: 13,
                          color: running.isDeload ? Colors.amber : primary)),
                  if (running.phase != null)
                    Text(_countsLine(running),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
          for (var i = 0; i < phases.length; i++)
            _PhaseCard(
              phase: phases[i],
              status: i < currentIndex
                  ? 'Done'
                  : i == currentIndex && running != null
                      ? 'Now · week ${running.pass}/${running.totalPasses}'
                      : null,
              sessions: [
                for (final s in sessions)
                  if (s.phaseId == phases[i].id)
                    (
                      id: s.id,
                      workoutId: s.workoutId,
                      name: workoutName(s.workoutId),
                      // Ticked once done or skipped in the week under way.
                      doneThisWeek: i == currentIndex &&
                          running != null &&
                          !running.phaseComplete &&
                          !running.remaining.contains(s.workoutId),
                    ),
              ],
              canMoveUp: i > 0,
              canMoveDown: i < phases.length - 1,
              onEdit: () => _editPhase(context, ref, phases[i]),
              onMove: (delta) {
                final ids = phases.map((p) => p.id).toList();
                final moved = ids.removeAt(i);
                ids.insert(i + delta, moved);
                ref.reorderPhases(ids);
              },
              onDelete: () => _deletePhase(context, ref, phases[i]),
              onAddSession: () => onAddSession(phases[i].id),
              onRemoveSession: ref.removePhaseSession,
              onOpenWorkout: (id) => context.push('/workouts/$id'),
              onTargets: () => _showTargets(context, phases[i], [
                for (final s in sessions)
                  if (s.phaseId == phases[i].id) s.workoutId
              ]),
            ),
        ],
      ],
    );
  }

  static String _progressLine(PlanState s) {
    if (s.planComplete) return 'Plan complete';
    final parts = ['${s.phase!.name} · week ${s.pass}/${s.totalPasses}'];
    if (s.phaseComplete) {
      parts.add('phase done');
    } else if (s.isDeload) {
      parts.add('deload');
    } else if (s.passesUntilDeload != null) {
      parts.add('deload in ${s.passesUntilDeload}');
    }
    return parts.join(' · ');
  }

  static String _countsLine(PlanState s) {
    final done =
        s.sessionsDone == 1 ? '1 session done' : '${s.sessionsDone} sessions done';
    final left = s.phaseComplete || s.remaining.isEmpty
        ? null
        : '${s.remaining.length} left this week';
    return [
      done,
      if (s.sessionsSkipped > 0) '${s.sessionsSkipped} skipped',
      if (left != null) left,
    ].join(' \u00b7 ');
  }

  Future<void> _addPhase(BuildContext context, WidgetRef ref) async {
    final result = await showPhaseDialog(context, title: 'New phase');
    if (result == null) return;
    await ref.insertPhase(planId, result.name,
        lengthPasses: result.weeks, deloadEvery: result.deloadEvery);
  }

  Future<void> _editPhase(
      BuildContext context, WidgetRef ref, PlanPhase phase) async {
    final result = await showPhaseDialog(
      context,
      title: 'Edit phase',
      initial: (
        name: phase.name,
        weeks: phase.lengthPasses,
        deloadEvery: phase.deloadEvery,
      ),
    );
    if (result == null) return;
    await ref.updatePhase(phase.id,
        name: result.name,
        lengthPasses: result.weeks,
        deloadEvery: result.deloadEvery);
  }

  Future<void> _deletePhase(
      BuildContext context, WidgetRef ref, PlanPhase phase) async {
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await ref.deletePhase(phase.id);
    if (deleted == null) return;
    showUndoSnackBar(messenger,
        message: 'Deleted "${phase.name}"',
        onUndo: () => ref.restorePhase(deleted));
  }

  void _showTargets(
      BuildContext context, PlanPhase phase, List<int> workoutIds) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _PhaseTargetsSheet(phase: phase, workoutIds: workoutIds),
    );
  }
}

// ── Phase card ────────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final PlanPhase phase;
  final String? status;
  final List<({int id, int workoutId, String name, bool doneThisWeek})>
      sessions;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onEdit;
  final void Function(int delta) onMove;
  final VoidCallback onDelete;
  final VoidCallback onAddSession;
  final void Function(int sessionId) onRemoveSession;
  final void Function(int workoutId) onOpenWorkout;
  final VoidCallback onTargets;

  const _PhaseCard({
    required this.phase,
    required this.status,
    required this.sessions,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
    required this.onAddSession,
    required this.onRemoveSession,
    required this.onOpenWorkout,
    required this.onTargets,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final every = phase.deloadEvery;
    final summary = [
      '${phase.lengthPasses} ${phase.lengthPasses == 1 ? 'week' : 'weeks'}',
      switch (every) {
        null => 'no deloads',
        1 => 'every week a deload',
        _ => 'deload every ${_ordinal(every)} week',
      },
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(phase.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(summary,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                  ),
                ),
                if (status != null)
                  Text(status!,
                      style: TextStyle(
                          fontSize: 12,
                          color: status == 'Done'
                              ? Colors.white.withValues(alpha: 0.4)
                              : primary)),
                PopupMenuButton<_PhaseAction>(
                  icon: Icon(Icons.more_vert,
                      size: 20, color: Colors.white.withValues(alpha: 0.4)),
                  onSelected: (a) => switch (a) {
                    _PhaseAction.edit => onEdit(),
                    _PhaseAction.targets => onTargets(),
                    _PhaseAction.moveUp => onMove(-1),
                    _PhaseAction.moveDown => onMove(1),
                    _PhaseAction.delete => onDelete(),
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: _PhaseAction.edit, child: Text('Edit')),
                    const PopupMenuItem(
                        value: _PhaseAction.targets,
                        child: Text('RPE targets')),
                    if (canMoveUp)
                      const PopupMenuItem(
                          value: _PhaseAction.moveUp, child: Text('Move up')),
                    if (canMoveDown)
                      const PopupMenuItem(
                          value: _PhaseAction.moveDown,
                          child: Text('Move down')),
                    const PopupMenuItem(
                        value: _PhaseAction.delete, child: Text('Delete')),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in sessions)
                  InputChip(
                    avatar: s.doneThisWeek
                        ? Icon(Icons.check, size: 16, color: primary)
                        : null,
                    label: Text(s.name),
                    onPressed: () => onOpenWorkout(s.workoutId),
                    onDeleted: () => onRemoveSession(s.id),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 14),
                  label: const Text('Session'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAddSession,
                ),
                if (sessions.isNotEmpty)
                  ActionChip(
                    avatar: const Icon(Icons.tune, size: 14),
                    label: const Text('RPE targets'),
                    visualDensity: VisualDensity.compact,
                    onPressed: onTargets,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _ordinal(int n) => switch (n) {
        2 => '2nd',
        3 => '3rd',
        _ => '${n}th',
      };
}

enum _PhaseAction { edit, targets, moveUp, moveDown, delete }

// ── Phase dialog ──────────────────────────────────────────────────────────────

typedef PhaseFields = ({String name, int weeks, int? deloadEvery});

/// Asks for a phase's name, length and deload rule; null if cancelled.
Future<PhaseFields?> showPhaseDialog(BuildContext context,
        {required String title, PhaseFields? initial}) =>
    showDialog<PhaseFields>(
      context: context,
      useRootNavigator: false,
      builder: (_) => _PhaseDialog(title: title, initial: initial),
    );

class _PhaseDialog extends StatefulWidget {
  final String title;
  final PhaseFields? initial;
  const _PhaseDialog({required this.title, this.initial});

  @override
  State<_PhaseDialog> createState() => _PhaseDialogState();
}

class _PhaseDialogState extends State<_PhaseDialog> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _weeks =
      TextEditingController(text: '${widget.initial?.weeks ?? 10}');
  late final _every = TextEditingController(
      text: widget.initial == null
          ? '4'
          : widget.initial!.deloadEvery?.toString() ?? '');

  @override
  void dispose() {
    _name.dispose();
    _weeks.dispose();
    _every.dispose();
    super.dispose();
  }

  PhaseFields? get _fields {
    final name = _name.text.trim();
    final weeks = int.tryParse(_weeks.text.trim());
    final every = int.tryParse(_every.text.trim());
    if (name.isEmpty || weeks == null || weeks < 1) return null;
    return (
      name: name,
      weeks: weeks,
      deloadEvery: every != null && every > 0 ? every : null,
    );
  }

  void _save() {
    final f = _fields;
    if (f != null) Navigator.pop(context, f);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: widget.initial == null,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Name', hintText: 'e.g. Capacity'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeks,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Length in weeks',
                helperText: 'A week is one pass through the rotation',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _every,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Deload every … weeks',
                helperText: 'Blank for no scheduled deloads',
              ),
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

// ── Phase RPE targets ─────────────────────────────────────────────────────────

/// Every exercise in a phase's rotation, with the workout's own target and the
/// phase's override for it.
class _PhaseTargetsSheet extends ConsumerWidget {
  final PlanPhase phase;
  final List<int> workoutIds;
  const _PhaseTargetsSheet({required this.phase, required this.workoutIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = {
      for (final t in ref.watch(phaseTargetsProvider(phase.id)).value ?? [])
        t.categoryId: t,
    };
    // An exercise in several sessions is listed once, with the first
    // session's target as its base — the override applies to all of them.
    final exercises = <int, WorkoutExerciseEntry>{};
    for (final w in workoutIds) {
      for (final e in ref.watch(workoutExercisesProvider(w)).value ??
          const <WorkoutExerciseEntry>[]) {
        exercises.putIfAbsent(e.category.id, () => e);
      }
    }
    final primary = Theme.of(context).colorScheme.primary;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text('${phase.name} targets',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Overrides apply to the exercise in every session of this '
              'phase. A deload week drops every target to RPE $kDeloadRpe.',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No exercises in this phase\'s sessions yet.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            ),
          for (final WorkoutExerciseEntry(category: cat, :target)
              in exercises.values)
            Builder(builder: (context) {
              final o = overrides[cat.id];
              final base = formatTarget(target);
              final phaseTarget = o == null
                  ? null
                  : formatTarget(
                      resolveTarget(target, o.target, deload: false));
              return ListTile(
                title: Text(cat.name),
                subtitle: Text('Workout: ${base ?? 'no target'}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45))),
                trailing: Text(phaseTarget ?? 'as workout',
                    style: TextStyle(
                        fontSize: 13,
                        color: o == null
                            ? Colors.white.withValues(alpha: 0.35)
                            : primary)),
                onTap: () => _edit(context, ref, cat, o),
              );
            }),
        ],
      ),
    );
  }

  void _edit(BuildContext context, WidgetRef ref, ExerciseCategory cat,
      PhaseExerciseTarget? current) {
    final rpe =
        TextEditingController(text: current?.targetRpe?.toString() ?? '');
    final sets =
        TextEditingController(text: current?.targetSets?.toString() ?? '');
    final reps =
        TextEditingController(text: current?.targetReps?.toString() ?? '');
    int? parse(TextEditingController c) => int.tryParse(c.text.trim());

    void save(BuildContext dialogCtx, {bool clear = false}) {
      final r = clear ? null : parse(rpe);
      ref.setPhaseExerciseTarget(
        phase.id,
        cat.id,
        Target(
          rpe: r != null && r >= 1 && r <= 10 ? r : null,
          sets: clear ? null : parse(sets),
          reps: clear ? null : parse(reps),
        ),
      );
      Navigator.pop(dialogCtx);
    }

    Widget field(TextEditingController c, String label,
            {bool autofocus = false}) =>
        Expanded(
          child: TextField(
            controller: c,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(labelText: label, hintText: '—'),
          ),
        );

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) => AlertDialog(
        title: Text(cat.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('In ${phase.name}. Blank keeps the workout\'s own value.',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            Row(children: [
              field(rpe, 'RPE', autofocus: true),
              const SizedBox(width: 12),
              field(sets, 'Sets'),
              const SizedBox(width: 12),
              field(reps, 'Reps'),
            ]),
          ],
        ),
        actions: [
          if (current != null)
            TextButton(
                onPressed: () => save(dialogCtx, clear: true),
                child: const Text('Clear')),
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => save(dialogCtx), child: const Text('Save')),
        ],
      ),
    );
  }
}
