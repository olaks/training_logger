import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'tabs/track_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/graph_tab.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int    categoryId;
  final String dateStr;
  const ExerciseDetailScreen(
      {super.key, required this.categoryId, required this.dateStr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catAsync   = ref.watch(categoryByIdProvider(categoryId));
    final cat        = catAsync.value;
    final name       = cat?.name ?? 'Exercise';
    final exType = cat?.exerciseType ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            if (cat != null)
              PopupMenuButton<int>(
                onSelected: (type) => ref.setExerciseType(categoryId, type),
                itemBuilder: (_) => [
                  if (exType != 0)
                    PopupMenuItem(
                      value: 0,
                      child: Row(children: [
                        Icon(Icons.fitness_center, size: 18,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const Text('Standard'),
                      ]),
                    ),
                  if (exType != 1)
                    PopupMenuItem(
                      value: 1,
                      child: Row(children: [
                        Icon(Icons.terrain, size: 18,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const Text('Climbing'),
                      ]),
                    ),
                  if (exType != 2)
                    PopupMenuItem(
                      value: 2,
                      child: Row(children: [
                        Icon(Icons.timer, size: 18,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        const Text('Hangboard'),
                      ]),
                    ),
                ],
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'TRACK'),
              Tab(text: 'HISTORY'),
              Tab(text: 'GRAPH'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            TrackTab(categoryId: categoryId, dateStr: dateStr),
            HistoryTab(categoryId: categoryId),
            GraphTab(categoryId: categoryId),
          ],
        ),
      ),
    );
  }
}
