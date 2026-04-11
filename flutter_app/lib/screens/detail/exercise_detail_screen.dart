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
    final catAsync = ref.watch(categoryByIdProvider(categoryId));
    final name     = catAsync.value?.name ?? 'Exercise';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
