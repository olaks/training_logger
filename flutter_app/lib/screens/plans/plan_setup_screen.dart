import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/periodization.dart';
import '../../utils/plan_setup.dart';

/// The guided way to set up a periodized plan: the shape of the year, one
/// training cycle, what each phase changes about it, and a review — the plan
/// is written only when the review is applied. Opens on the plan as it
/// stands, so it serves for reworking a plan as well as starting one.
class PlanSetupScreen extends ConsumerStatefulWidget {
  final int planId;
  const PlanSetupScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends ConsumerState<PlanSetupScreen> {
  PlanSetup? _setup;
  var _step = 0;
  var _dirty = false;
  var _applying = false;

  void _edit(VoidCallback change) => setState(() {
        change();
        _dirty = true;
      });

  @override
  Widget build(BuildContext context) {
    final plan = ref
        .watch(allPlansProvider)
        .value
        ?.where((p) => p.id == widget.planId)
        .firstOrNull;
    final phases = ref.watch(planPhasesProvider(widget.planId)).value;
    final sessions = ref.watch(planSessionsProvider(widget.planId)).value;
    final events = ref.watch(planEventsProvider(widget.planId)).value;
    if (plan == null || phases == null || sessions == null || events == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Read once: from here on the guide's draft is what is being edited.
    final setup = _setup ??= PlanSetup.fromPlan(plan, phases, sessions);
    final unit = cycleWord(setup.cycleDays);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          setState(() => _dirty = false);
          _leave();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Set up ${plan.name}')),
        body: Stepper(
          currentStep: _step,
          onStepTapped: (s) => setState(() => _step = s),
          onStepContinue: _step < 3
              ? () => setState(() => _step++)
              : _applying
                  ? null
                  : () => _apply(setup),
          onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
          controlsBuilder: (context, d) => Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Row(children: [
              FilledButton(
                  onPressed: d.onStepContinue,
                  child: Text(_step == 3 ? 'Apply to plan' : 'Next')),
              const SizedBox(width: 8),
              if (_step > 0)
                TextButton(
                    onPressed: d.onStepCancel, child: const Text('Back')),
            ]),
          ),
          steps: [
            Step(
              title: const Text('Shape of the year'),
              subtitle: Text('${setup.phases.length} phases · '
                  '${setup.cycleDays}-day $unit · '
                  'about ${(setup.totalDays / 7).round()} weeks'),
              isActive: true,
              content: _ShapeStep(setup: setup, onEdit: _edit),
            ),
            Step(
              title: const Text('Your training cycle'),
              subtitle: Text('${trainingDays(setup.template)} training days '
                  'in ${setup.cycleDays}'),
              isActive: _step >= 1,
              content: _CycleEditor(
                days: setup.cycleDays,
                cycle: setup.template,
                onEdit: _edit,
              ),
            ),
            Step(
              title: const Text('Changes per phase'),
              subtitle: Text(
                  '${setup.phases.where((p) => p.own != null).length} of '
                  '${setup.phases.length} change the cycle'),
              isActive: _step >= 2,
              content: _PhasesStep(setup: setup, onEdit: _edit),
            ),
            Step(
              title: const Text('Review'),
              isActive: _step >= 3,
              content: _ReviewStep(
                setup: setup,
                // What applying would delete: phases the guide dropped.
                dropped: [
                  for (final p in phases)
                    if (!setup.phases.any((d) => d.id == p.id))
                      (
                        name: p.name,
                        logged: events
                            .where((e) =>
                                e.phaseId == p.id && e.workoutId != null)
                            .length,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Discard the setup?'),
          content: const Text('Nothing has been written to the plan yet.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: const Text('Keep editing')),
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                child: const Text('Discard')),
          ],
        ),
      ) ??
      false;

  Future<void> _apply(PlanSetup setup) async {
    for (var i = 0; i < setup.phases.length; i++) {
      final p = setup.phases[i];
      if (p.name.trim().isEmpty) p.name = 'Phase ${i + 1}';
      p.name = p.name.trim();
    }
    setState(() => _applying = true);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(dbProvider).applyPlanSetup(widget.planId, setup);
    if (!mounted) return;
    setState(() => _dirty = false);
    messenger.showSnackBar(const SnackBar(content: Text('Plan set up')));
    _leave();
  }

  /// Back to where the guide was opened from, or to the plan when it was
  /// opened directly (a link on the web).
  void _leave() => context.canPop()
      ? context.pop()
      : context.go('/plans/${widget.planId}');
}

// ── Step 1: the year ──────────────────────────────────────────────────────────

class _ShapeStep extends StatelessWidget {
  final PlanSetup setup;
  final void Function(VoidCallback) onEdit;
  const _ShapeStep({required this.setup, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final unit = cycleWord(setup.cycleDays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(child: Text('Days in a cycle')),
          _Counter(
            label: setup.cycleDays == 1 ? 'day' : 'days',
            value: setup.cycleDays,
            min: 1,
            max: 28,
            onChanged: (v) => onEdit(() => setup.cycleDays = v),
          ),
        ]),
        const SizedBox(height: 8),
        _YearBar(setup: setup),
        const SizedBox(height: 4),
        for (final p in setup.phases)
          Row(children: [
            Expanded(
              child: TextFormField(
                // Keyed by the draft so a removal doesn't shift the text of
                // the rows below it.
                key: ObjectKey(p),
                initialValue: p.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(isDense: true),
                onChanged: (v) => onEdit(() => p.name = v),
              ),
            ),
            _Counter(
              label: p.cycles == 1 ? unit : '${unit}s',
              value: p.cycles,
              min: 1,
              max: 52,
              onChanged: (v) => onEdit(() => p.cycles = v),
            ),
            IconButton(
              tooltip: 'Remove ${p.name}',
              visualDensity: VisualDensity.compact,
              onPressed: setup.phases.length > 1
                  ? () => onEdit(() => setup.phases.remove(p))
                  : null,
              icon: const Icon(Icons.close, size: 18),
            ),
          ]),
        Wrap(spacing: 8, children: [
          TextButton.icon(
            onPressed: () => onEdit(() => setup.phases.add(PhaseDraft(
                'Phase ${setup.phases.length + 1}',
                4,
                setup.phases.lastOrNull?.deloadEvery))),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add phase'),
          ),
          if (setup.phases.every((p) => p.id == null))
            TextButton(
              onPressed: () => onEdit(() => setup.phases = classicYear()),
              child: const Text('Use a classic year'),
            ),
        ]),
      ],
    );
  }
}

/// Each phase's share of the year, to scale.
class _YearBar extends StatelessWidget {
  final PlanSetup setup;
  const _YearBar({required this.setup});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(children: [
        for (var i = 0; i < setup.phases.length; i++)
          Expanded(
            flex: setup.phases[i].cycles,
            child: Container(
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              color: primary.withValues(alpha: i.isEven ? 0.85 : 0.45),
              child: Text(setup.phases[i].name,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
      ]),
    );
  }
}

// ── Steps 2 and 3: cycles ─────────────────────────────────────────────────────

/// One cycle, a row per day; tapping a day picks its workouts.
class _CycleEditor extends ConsumerWidget {
  final int days;
  final Cycle cycle;
  final void Function(VoidCallback) onEdit;
  const _CycleEditor(
      {required this.days, required this.cycle, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _workoutNames(ref);
    final muted = Colors.white.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var day = 1; day <= days; day++)
          InkWell(
            onTap: () async {
              final picked = await _pickWorkouts(context, ref,
                  title: 'Day $day', initial: cycle[day] ?? const []);
              if (picked == null) return;
              onEdit(() => picked.isEmpty
                  ? cycle.remove(day)
                  : cycle[day] = picked);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                SizedBox(
                    width: 52,
                    child: Text('Day $day',
                        style: TextStyle(fontSize: 12, color: muted))),
                Expanded(
                  child: (cycle[day] ?? const []).isEmpty
                      ? Text('Rest',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.3)))
                      : Text(cycle[day]!.map(name).join(' · ')),
                ),
                Icon(Icons.edit_outlined, size: 16, color: muted),
              ]),
            ),
          ),
      ],
    );
  }
}

class _PhasesStep extends StatelessWidget {
  final PlanSetup setup;
  final void Function(VoidCallback) onEdit;
  const _PhasesStep({required this.setup, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final unit = cycleWord(setup.cycleDays);
    return Column(
      children: [
        for (final p in setup.phases)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(children: [
              SwitchListTile(
                title: Text(p.name),
                subtitle: Text(p.own == null
                    ? 'Runs your training cycle'
                    : 'Runs its own version of it'),
                value: p.own != null,
                onChanged: (v) => onEdit(
                    () => p.own = v ? copyCycle(setup.template) : null),
              ),
              if (p.own != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 12, 4),
                  child: _CycleEditor(
                      days: setup.cycleDays, cycle: p.own!, onEdit: onEdit),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 4, 4),
                child: Row(children: [
                  const Expanded(child: Text('Deloads')),
                  DropdownButton<int?>(
                    value: p.deloadEvery,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => onEdit(() => p.deloadEvery = v),
                    // Every rule the editor allows, so a phase made there
                    // always finds its own in the list.
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('None')),
                      for (final n in <int>{
                        for (var n = 1; n <= 12; n++) n,
                        if (p.deloadEvery != null) p.deloadEvery!,
                      })
                        DropdownMenuItem(
                            value: n,
                            child: Text(n == 1
                                ? 'Every $unit'
                                : 'Every ${_ordinal(n)} $unit')),
                    ],
                  ),
                ]),
              ),
            ]),
          ),
      ],
    );
  }

  static String _ordinal(int n) => switch (n) {
        2 => '2nd',
        3 => '3rd',
        _ => '${n}th',
      };
}

// ── Step 4: review ────────────────────────────────────────────────────────────

/// The year as it will be written: every phase's cycle side by side, days
/// down and phases across, and what applying it would delete.
class _ReviewStep extends ConsumerWidget {
  final PlanSetup setup;
  final List<({String name, int logged})> dropped;
  const _ReviewStep({required this.setup, required this.dropped});

  static const _dayCol = 48.0;
  static const _phaseCol = 132.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _workoutNames(ref);
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Colors.white.withValues(alpha: 0.5);
    final unit = cycleWord(setup.cycleDays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const SizedBox(width: _dayCol),
                for (final p in setup.phases)
                  SizedBox(
                    width: _phaseCol,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text('${p.cycles} ${p.cycles == 1 ? unit : '${unit}s'}',
                              style: TextStyle(fontSize: 11, color: muted)),
                        ],
                      ),
                    ),
                  ),
              ]),
              for (var day = 1; day <= setup.cycleDays; day++)
                Row(children: [
                  SizedBox(
                    width: _dayCol,
                    child: Text('Day $day',
                        style: TextStyle(fontSize: 11, color: muted)),
                  ),
                  for (final p in setup.phases)
                    Container(
                      width: _phaseCol - 4,
                      height: 44,
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (setup.cycleOf(p)[day] ?? const []).isEmpty
                            ? Colors.white.withValues(alpha: 0.03)
                            : primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _cellText(setup.cycleOf(p)[day] ?? const [], name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            color: (setup.cycleOf(p)[day] ?? const []).isEmpty
                                ? Colors.white.withValues(alpha: 0.3)
                                : null),
                      ),
                    ),
                ]),
            ],
          ),
        ),
        for (final d in dropped)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              d.logged == 0
                  ? 'Removes ${d.name}.'
                  : 'Removes ${d.name}, and the ${d.logged} '
                      '${d.logged == 1 ? 'session' : 'sessions'} logged in it.',
              style: const TextStyle(color: Colors.amber),
            ),
          ),
      ],
    );
  }
}

/// A review cell's two lines: the first workout, then the second or how
/// many more there are, so a cell never hides one without saying so.
String _cellText(List<int> workouts, String Function(int) name) =>
    switch (workouts) {
      [] => 'Rest',
      [final w] => name(w),
      [final w, final x] => '${name(w)}\n${name(x)}',
      [final w, ...final more] => '${name(w)}\n+${more.length} more',
    };

// ── Shared pieces ─────────────────────────────────────────────────────────────

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Counter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text('$value $label'),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      );
}

String Function(int) _workoutNames(WidgetRef ref) {
  final byId = {
    for (final w in ref.watch(allWorkoutsProvider).value ?? const <Workout>[])
      w.id: w.name,
  };
  return (id) => byId[id] ?? '?';
}

/// Picks a day's workouts, keeping the ones already chosen in their order;
/// an empty list makes it a rest day. Null if cancelled.
Future<List<int>?> _pickWorkouts(BuildContext context, WidgetRef ref,
    {required String title, required List<int> initial}) {
  final workouts = [...ref.read(allWorkoutsProvider).value ?? const <Workout>[]]
    ..sort((x, y) => x.name.toLowerCase().compareTo(y.name.toLowerCase()));
  final chosen = [...initial];
  return showDialog<List<int>>(
    context: context,
    useRootNavigator: false,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (_, setState) => AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
        content: SizedBox(
          width: 320,
          child: workouts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No workouts yet. Create some under Plans.'),
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final w in workouts)
                      CheckboxListTile(
                        dense: true,
                        value: chosen.contains(w.id),
                        title: Text(w.name),
                        onChanged: (v) => setState(() =>
                            v! ? chosen.add(w.id) : chosen.remove(w.id)),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, <int>[]),
              child: const Text('Rest day')),
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, chosen),
              child: const Text('Done')),
        ],
      ),
    ),
  );
}
