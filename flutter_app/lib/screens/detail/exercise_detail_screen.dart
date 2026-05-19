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
    final description = cat?.description;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            if (cat != null)
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Edit description',
                onPressed: () =>
                    _showDescriptionDialog(context, ref, name, description),
              ),
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
        body: Column(
          children: [
            if (description != null && description.isNotEmpty)
              _DescriptionBanner(text: description),
            Expanded(
              child: TabBarView(
                children: [
                  TrackTab(categoryId: categoryId, dateStr: dateStr),
                  HistoryTab(categoryId: categoryId),
                  GraphTab(categoryId: categoryId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog(
      BuildContext context, WidgetRef ref, String name, String? current) {
    final ctrl = TextEditingController(text: current ?? '');
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        title: Text('Description — $name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Cues, setup, notes… (leave empty to clear)'),
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: 8,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = ctrl.text.trim();
              ref.updateCategoryDescription(categoryId, v.isEmpty ? null : v);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DescriptionBanner extends StatelessWidget {
  final String text;
  const _DescriptionBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.35,
          color: Colors.white.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}
