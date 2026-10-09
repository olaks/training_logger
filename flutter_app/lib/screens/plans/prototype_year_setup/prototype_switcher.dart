// PROTOTYPE — throwaway. Mounts the year-setup variants on /plans/:id:
//
//   /plans/1?variant=current   the editor as it is today
//   /plans/1?variant=A         Guided builder (stepper, template cycle)
//   /plans/1?variant=B         Cycle grid (days × phases matrix)
//
// Debug builds only: app.dart only routes here under kDebugMode.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../plan_detail_screen.dart';
import 'variant_a_guided.dart';
import 'variant_b_grid.dart';

const _variants = {
  'current': 'Today\'s editor',
  'A': 'Guided builder',
  'B': 'Cycle grid',
};

class YearSetupPrototype extends StatelessWidget {
  final int planId;
  final String variant;
  const YearSetupPrototype(
      {super.key, required this.planId, required this.variant});

  @override
  Widget build(BuildContext context) {
    final page = switch (variant) {
      'A' => GuidedBuilder(planId: planId),
      'B' => CycleGrid(planId: planId),
      _ => PlanDetailScreen(planId: planId),
    };
    return Stack(
      children: [
        page,
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(child: _Switcher(planId: planId, current: variant)),
        ),
      ],
    );
  }
}

class _Switcher extends StatelessWidget {
  final int planId;
  final String current;
  const _Switcher({required this.planId, required this.current});

  void _go(BuildContext context, int delta) {
    final keys = _variants.keys.toList();
    final i = keys.indexOf(current);
    final next = keys[(i + delta) % keys.length];
    context.replace('/plans/$planId?variant=$next');
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft) _go(context, -1);
        if (e.logicalKey == LogicalKeyboardKey.arrowRight) _go(context, 1);
        return KeyEventResult.ignored;
      },
      child: Material(
        color: Colors.black,
        elevation: 8,
        shape: const StadiumBorder(side: BorderSide(color: Colors.white54)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () => _go(context, -1),
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
            Text('PROTOTYPE  $current · ${_variants[current] ?? '?'}',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            IconButton(
                onPressed: () => _go(context, 1),
                icon: const Icon(Icons.chevron_right, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
