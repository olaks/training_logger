import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/youtube.dart';
import '../inspiration/inspiration_screen.dart';
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
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit exercise',
                onPressed: () => context.push('/exercise/$categoryId/edit'),
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
            _VideosRow(categoryId: categoryId),
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

class _VideosRow extends ConsumerWidget {
  final int categoryId;
  const _VideosRow({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(inspirationsProvider(categoryId)).value ?? [];
    final categories = ref.watch(categoriesProvider).value ?? [];

    return Container(
      height: 88,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        itemCount: videos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == videos.length) {
            return _AddVideoTile(
              onTap: () => showInspirationFormSheet(
                context,
                categories: categories,
                defaultCategoryId: categoryId,
              ),
            );
          }
          final v = videos[i];
          return _VideoTile(
            inspiration: v,
            onTap: () => _open(context, v.url),
            onEdit: () => showInspirationFormSheet(
              context,
              categories: categories,
              existing: v,
              defaultCategoryId: categoryId,
            ),
            onDelete: () => _confirmDelete(context, ref, v),
          );
        },
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Inspiration item) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => AlertDialog(
        content: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.removeInspiration(item.id);
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

class _VideoTile extends StatelessWidget {
  final Inspiration inspiration;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VideoTile({
    required this.inspiration,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = youtubeThumbnail(inspiration.url);
    return SizedBox(
      width: 120,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showMenu(context),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 120,
                height: 44,
                child: thumb != null
                    ? Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _Placeholder(),
                      )
                    : _Placeholder(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              inspiration.title,
              style: const TextStyle(fontSize: 11, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVideoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddVideoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add,
                    size: 22, color: Colors.white.withValues(alpha: 0.55)),
                const SizedBox(height: 2),
                Text('Add video',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.55))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.play_circle_outline,
            color: Colors.white.withValues(alpha: 0.3), size: 22),
      );
}
