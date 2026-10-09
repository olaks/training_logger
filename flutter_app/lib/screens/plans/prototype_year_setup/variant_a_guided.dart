// PROTOTYPE — throwaway. Variant A: a guided builder. Four steps — the
// year's shape, one template cycle, which phases change it, review — held in
// memory and written to the plan only on "Apply". The cycle is built once and
// every phase starts from it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/periodization.dart';
import 'shared.dart';

class _Phase {
  int? id; // null until applied
  String name;
  int cycles;
  int? deloadEvery;
  Cycle? own; // null: uses the template
  _Phase(this.name, this.cycles, this.deloadEvery, {this.id, this.own});
}

/// The year most people start from.
List<_Phase> _classicYear() => [
      _Phase('Capacity', 8, 4),
      _Phase('Basic strength', 10, 4),
      _Phase('Max strength', 8, 3),
      _Phase('Peak', 4, null),
    ];

class GuidedBuilder extends ConsumerStatefulWidget {
  final int planId;
  const GuidedBuilder({super.key, required this.planId});

  @override
  ConsumerState<GuidedBuilder> createState() => _GuidedBuilderState();
}

class _GuidedBuilderState extends ConsumerState<GuidedBuilder> {
  var _step = 0;
  var _loaded = false;
  var _days = 8;
  var _phases = <_Phase>[];
  Cycle _template = {};

  /// Starts from the plan as it is: its phases, and the first phase's cycle
  /// as the template, the others customised only where they differ from it.
  void _load(Plan plan, List<PlanPhase> phases, List<PhaseSession> sessions) {
    final cycles = cyclesOf(phases, sessions);
    _days = plan.cycleDays;
    _template = phases.isEmpty ? {} : _copy(cycles[phases.first.id]!);
    _phases = [
      for (final p in phases)
        _Phase(p.name, p.lengthPasses, p.deloadEvery,
            id: p.id,
            own: _same(cycles[p.id]!, _template) ? null : _copy(cycles[p.id]!)),
    ];
    if (_phases.isEmpty) _phases = _classicYear();
    _loaded = true;
  }

  static Cycle _copy(Cycle c) => {for (final e in c.entries) e.key: [...e.value]};
  static bool _same(Cycle a, Cycle b) {
    final days = {...a.keys, ...b.keys};
    return days.every((d) =>
        (a[d] ?? const []).join(',') == (b[d] ?? const []).join(','));
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref
        .watch(allPlansProvider)
        .value
        ?.where((p) => p.id == widget.planId)
        .firstOrNull;
    final phases = ref.watch(planPhasesProvider(widget.planId)).value;
    final sessions = ref.watch(planSessionsProvider(widget.planId)).value;
    if (plan == null || phases == null || sessions == null) {
      return const Scaffold();
    }
    if (!_loaded) _load(plan, phases, sessions);

    return Scaffold(
      appBar: AppBar(title: Text('Set up ${plan.name}')),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (s) => setState(() => _step = s),
        onStepContinue: _step < 3
            ? () => setState(() => _step++)
            : () => _apply(phases, sessions),
        onStepCancel: _step > 0 ? () => setState(() => _step--) : null,
        controlsBuilder: (context, d) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(children: [
            FilledButton(
                onPressed: d.onStepContinue,
                child: Text(_step == 3 ? 'Apply to plan' : 'Next')),
            const SizedBox(width: 8),
            if (_step > 0)
              TextButton(onPressed: d.onStepCancel, child: const Text('Back')),
          ]),
        ),
        steps: [
          Step(
            title: const Text('Shape of the year'),
            subtitle: Text(_shapeLine()),
            isActive: _step >= 0,
            content: _shapeStep(),
          ),
          Step(
            title: const Text('Your training cycle'),
            subtitle: Text('${_trainingDays(_template)} training days in '
                '$_days'),
            isActive: _step >= 1,
            content: _CycleEditor(
              days: _days,
              cycle: _template,
              onChanged: () => setState(() {}),
            ),
          ),
          Step(
            title: const Text('Changes per phase'),
            subtitle: Text(
                '${_phases.where((p) => p.own != null).length} of '
                '${_phases.length} phases change the cycle'),
            isActive: _step >= 2,
            content: _perPhaseStep(),
          ),
          Step(
            title: const Text('Review'),
            isActive: _step >= 3,
            content: _reviewStep(),
          ),
        ],
      ),
    );
  }

  int get _totalDays =>
      _phases.fold(0, (n, p) => n + p.cycles * _days);

  String _shapeLine() => '${_phases.length} phases · $_days-day '
      '${cycleWord(_days)} · about ${(_totalDays / 7).round()} weeks';

  static int _trainingDays(Cycle c) =>
      c.values.where((w) => w.isNotEmpty).length;

  Widget _stepper(String label, int value, int min, int max,
          void Function(int) set) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: value > min ? () => setState(() => set(value - 1)) : null,
              icon: const Icon(Icons.remove, size: 18)),
          Text('$value $label'),
          IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: value < max ? () => setState(() => set(value + 1)) : null,
              icon: const Icon(Icons.add, size: 18)),
        ],
      );

  Widget _shapeStep() {
    final primary = Theme.of(context).colorScheme.primary;
    final unit = cycleWord(_days);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Expanded(child: Text('Days in a cycle')),
          _stepper('days', _days, 1, 28, (v) => _days = v),
        ]),
        const SizedBox(height: 8),
        // The year, to scale.
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(children: [
            for (var i = 0; i < _phases.length; i++)
              Expanded(
                flex: _phases[i].cycles,
                child: Container(
                  height: 22,
                  alignment: Alignment.center,
                  color: primary.withValues(alpha: i.isEven ? 0.85 : 0.45),
                  child: Text(_phases[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 10)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _phases.length; i++)
          Row(children: [
            Expanded(
              child: TextFormField(
                key: ValueKey(_phases[i]),
                initialValue: _phases[i].name,
                decoration: const InputDecoration(isDense: true),
                onChanged: (v) => setState(() => _phases[i].name = v),
              ),
            ),
            _stepper('${unit}s', _phases[i].cycles, 1, 52,
                (v) => _phases[i].cycles = v),
            IconButton(
                tooltip: 'Remove',
                onPressed: _phases.length > 1
                    ? () => setState(() => _phases.removeAt(i))
                    : null,
                icon: const Icon(Icons.close, size: 18)),
          ]),
        Wrap(spacing: 8, children: [
          TextButton.icon(
            onPressed: () => setState(() => _phases.add(_Phase(
                'Phase ${_phases.length + 1}', 4, _phases.lastOrNull?.deloadEvery))),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add phase'),
          ),
          TextButton(
            onPressed: () => setState(() => _phases = _classicYear()),
            child: const Text('Use a classic year'),
          ),
        ]),
      ],
    );
  }

  Widget _perPhaseStep() => Column(
        children: [
          for (final p in _phases)
            Card(
              child: Column(children: [
                SwitchListTile(
                  title: Text(p.name),
                  subtitle: Text(p.own == null
                      ? 'Same cycle as the template'
                      : 'Its own version of the cycle'),
                  value: p.own != null,
                  onChanged: (v) =>
                      setState(() => p.own = v ? _copy(_template) : null),
                ),
                if (p.own != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: _CycleEditor(
                      days: _days,
                      cycle: p.own!,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                  child: Row(children: [
                    const Expanded(child: Text('Deload every')),
                    _stepper(cycleWord(_days), p.deloadEvery ?? 0, 0, 12,
                        (v) => p.deloadEvery = v == 0 ? null : v),
                  ]),
                ),
              ]),
            ),
        ],
      );

  Widget _reviewStep() {
    final name = workoutNamer(ref);
    final start = DateTime.now();
    var offset = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in _phases)
          Builder(builder: (_) {
            final from = start.add(Duration(days: offset));
            offset += p.cycles * _days;
            final cycle = p.own ?? _template;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${p.name} · ${p.cycles} ${cycleWord(_days)}s'),
              subtitle: Text(
                  'From ${from.day}/${from.month} · '
                  '${cycleWorkouts(cycle).map(name).join(', ')}'),
            );
          }),
      ],
    );
  }

  /// Writes the builder's plan over the real one: phases matched by
  /// position (so a phase in progress keeps its log), cycles replaced.
  Future<void> _apply(
      List<PlanPhase> existing, List<PhaseSession> sessions) async {
    final db = ref.read(dbProvider);
    for (final s in sessions) {
      await db.removePhaseSession(s.id);
    }
    await db.setCycleDays(widget.planId, _days);
    for (var i = 0; i < _phases.length; i++) {
      final p = _phases[i];
      final id = i < existing.length
          ? existing[i].id
          : await db.insertPhase(widget.planId, p.name,
              lengthPasses: p.cycles, deloadEvery: p.deloadEvery);
      if (i < existing.length) {
        await db.updatePhase(id,
            name: p.name, lengthPasses: p.cycles, deloadEvery: p.deloadEvery);
      }
      final cycle = p.own ?? _template;
      for (final day in cycle.keys.toList()..sort()) {
        if (day > _days) continue;
        for (final w in cycle[day]!) {
          await db.addSessionToPhase(id, w, day: day);
        }
      }
    }
    for (final extra in existing.skip(_phases.length)) {
      await db.deletePhase(extra.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Plan set up')));
    }
  }
}

/// Day-by-day editor for one cycle, held in memory.
class _CycleEditor extends ConsumerWidget {
  final int days;
  final Cycle cycle;
  final VoidCallback onChanged;
  const _CycleEditor(
      {required this.days, required this.cycle, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = workoutNamer(ref);
    final muted = Colors.white.withValues(alpha: 0.5);
    return Column(
      children: [
        for (var day = 1; day <= days; day++)
          InkWell(
            onTap: () async {
              final picked = await pickWorkouts(context, ref,
                  title: 'Day $day', initial: cycle[day] ?? const []);
              if (picked == null) return;
              cycle[day] = picked;
              onChanged();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                SizedBox(
                    width: 52,
                    child: Text('Day $day',
                        style: TextStyle(fontSize: 12, color: muted))),
                Expanded(
                  child: Text(
                    (cycle[day] ?? const []).isEmpty
                        ? 'Rest'
                        : cycle[day]!.map(name).join(' · '),
                    style: (cycle[day] ?? const []).isEmpty
                        ? TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.3))
                        : null,
                  ),
                ),
                Icon(Icons.edit_outlined, size: 16, color: muted),
              ]),
            ),
          ),
      ],
    );
  }
}
