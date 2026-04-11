import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../database/database.dart';
import '../../../providers/app_providers.dart';
import '../../../utils/format_utils.dart';

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
                style: TextStyle(color: Colors.white.withValues(alpha:0.35))),
          );
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
                ...daySets.asMap().entries.map((e) => _SetRow(
                      set:     e.value,
                      index:   e.key,
                      onDelete: () => _confirmDelete(context, ref, e.value.id),
                    )),
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
            onPressed: () {
              ref.removeSet(id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final WorkoutSet set;
  final int index;
  final VoidCallback onDelete;
  const _SetRow({required this.set, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text('Set ${index + 1}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha:0.4))),
              ),
              Expanded(
                child: Text(
                    formatSet(
                        weightKg: set.weightKg,
                        reps:     set.reps,
                        timeSecs: set.timeSecs),
                    style: const TextStyle(fontSize: 14)),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.error.withValues(alpha:0.5)),
              ),
            ],
          ),
        ),
      );
}
