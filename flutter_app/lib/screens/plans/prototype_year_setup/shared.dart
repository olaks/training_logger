// PROTOTYPE — throwaway. Two variants of setting up a year plan, switchable
// with ?variant= on /plans/:id in debug builds. See prototype_switcher.dart.
//
// Only the primitives both variants need live here: a multi-select workout
// picker and writing one day of a phase's cycle. No layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';

/// Picks any number of workouts, starting from [initial]; null if cancelled.
Future<List<int>?> pickWorkouts(BuildContext context, WidgetRef ref,
    {required String title, List<int> initial = const []}) {
  final workouts = ref.read(allWorkoutsProvider).value ?? const <Workout>[];
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
          child: ListView(
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

/// Makes [day] of [phaseId]'s cycle hold exactly [workoutIds], in order.
Future<void> writeDay(AppDatabase db, List<PhaseSession> sessions,
    int phaseId, int day, List<int> workoutIds) async {
  for (final s in sessions) {
    if (s.phaseId == phaseId && s.day == day) {
      await db.removePhaseSession(s.id);
    }
  }
  for (final w in workoutIds) {
    await db.addSessionToPhase(phaseId, w, day: day);
  }
}

/// Workout names by id, '?' for one that's gone.
String Function(int) workoutNamer(WidgetRef ref) {
  final byId = {
    for (final w in ref.watch(allWorkoutsProvider).value ?? const <Workout>[])
      w.id: w.name,
  };
  return (id) => byId[id] ?? '?';
}
