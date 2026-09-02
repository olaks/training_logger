import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/grades.dart';
import '../../../utils/undo_snackbar.dart';
import '../edit_set_sheet.dart';

class HistoryTab extends ConsumerWidget {
  final int categoryId;
  const HistoryTab({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setsAsync = ref.watch(setsForCategoryProvider(categoryId));

    return setsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('$e')),
      data:    (sets) {
        if (sets.isEmpty) {
          return Center(
            child: Text('No sets logged yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35))),
          );
        }

        // Compute all-time PR thresholds
        final isClimbing = sets.any((s) => s.grade != null);

        // Standard PRs (weight / reps / time)
        double? maxWeight;
        int? maxReps;
        int? maxTime;
        // Climbing PR (best grade index)
        int maxGradeIdx = -1;
        List<String> gradeScale = fontGrades;

        if (isClimbing) {
          final gradeStrings = sets
              .where((s) => s.grade != null)
              .map((s) => s.grade!);
          gradeScale = detectGradeScale(gradeStrings);
          for (final s in sets) {
            if (s.grade == null) continue;
            final idx = gradeToIndex(s.grade!, gradeScale);
            if (idx > maxGradeIdx) maxGradeIdx = idx;
          }
        } else {
          for (final s in sets) {
            if (s.weightKg != null &&
                (maxWeight == null || s.weightKg! > maxWeight)) {
              maxWeight = s.weightKg;
            }
            if (s.reps != null && (maxReps == null || s.reps! > maxReps)) {
              maxReps = s.reps;
            }
            if (s.timeSecs != null &&
                (maxTime == null || s.timeSecs! > maxTime)) {
              maxTime = s.timeSecs;
            }
          }
        }

        // Group by date (already sorted desc by date from DB)
        final grouped = <String, List<WorkoutSet>>{};
        for (final s in sets) {
          grouped.putIfAbsent(s.dateStr, () => []).add(s);
        }
        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
        final dateFmt = DateFormat('EEE, MMM d yyyy');

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: dates.length,
          itemBuilder: (_, i) {
            final dateStr = dates[i];
            final daySets = grouped[dateStr]!;
            final display = dateFmt.format(dateFromStr(dateStr));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text(display,
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.8,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600)),
                ),
                ...daySets.asMap().entries.map((e) {
                  final s = e.value;
                  bool isPr;
                  if (isClimbing) {
                    isPr = s.grade != null &&
                        gradeToIndex(s.grade!, gradeScale) == maxGradeIdx;
                  } else {
                    isPr =
                        (s.weightKg != null && s.weightKg == maxWeight) ||
                        (s.reps != null && s.reps == maxReps) ||
                        (s.timeSecs != null && s.timeSecs == maxTime);
                  }
                  return _SetRow(
                    set:      s,
                    index:    e.key,
                    isPr:     isPr,
                    onEdit:   () =>
                        showEditSetSheet(context, s, gradeScale: gradeScale),
                    onDelete: () => _confirmDelete(context, ref, s.id),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('Delete this set?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final deleted = await ref.removeSet(id);
              navigator.pop();
              if (deleted == null) return;
              showUndoSnackBar(messenger,
                  message: 'Set deleted',
                  onUndo: () => ref.restoreSet(deleted));
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _ClimbingSetLine extends StatelessWidget {
  final WorkoutSet set;
  const _ClimbingSetLine({required this.set});

  @override
  Widget build(BuildContext context) {
    final name = set.climbName?.trim();
    final hasName = name != null && name.isNotEmpty;
    final hasAngle = set.wallAngle != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(set.grade!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        if (hasName || hasAngle) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              [
                if (hasName) name,
                if (hasAngle) '${set.wallAngle}°',
              ].join(' · '),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  final WorkoutSet set;
  final int index;
  final bool isPr;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SetRow(
      {required this.set,
      required this.index,
      required this.isPr,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text('Set ${index + 1}',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.4))),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (set.grade != null)
                        _ClimbingSetLine(set: set)
                      else
                        Text(
                          formatSet(
                            weightKg: set.weightKg,
                            reps:     set.reps,
                            timeSecs: set.timeSecs,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      if (set.rpe != null)
                        Text(
                          'RPE ${set.rpe}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.8)),
                        ),
                    ],
                  ),
                ),
                if (isPr)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Tooltip(
                      message: 'Personal record',
                      child: Icon(Icons.star_rounded,
                          size: 17, color: Colors.amber),
                    ),
                  ),
                GestureDetector(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.35)),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
