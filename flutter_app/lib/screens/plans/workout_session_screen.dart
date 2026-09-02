import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../detail/tabs/track_tab.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final int workoutId;
  final String dateStr;
  const WorkoutSessionScreen({
    super.key,
    required this.workoutId,
    required this.dateStr,
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends ConsumerState<WorkoutSessionScreen> {
  final PageController _pageCtrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int i, int total) {
    if (i < 0 || i >= total) return;
    setState(() => _index = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(allWorkoutsProvider).value?.firstWhere(
          (w) => w.id == widget.workoutId,
          orElse: () =>
              Workout(id: widget.workoutId, name: '', notes: ''),
        );
    final exercises =
        ref.watch(workoutExercisesProvider(widget.workoutId)).value ?? [];
    final todaySets =
        ref.watch(setsForDayProvider(widget.dateStr)).value ?? [];
    final loggedIds = todaySets.map((s) => s.categoryId).toSet();

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(workout?.name ?? 'Workout')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This workout has no exercises yet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Clamp index if the exercise list shrinks while we're on it.
    final safeIndex = _index.clamp(0, exercises.length - 1);
    final current = exercises[safeIndex].$2;
    final isLast = safeIndex == exercises.length - 1;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout?.name ?? 'Workout',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${current.name}  ·  ${safeIndex + 1} of ${exercises.length}',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // The session shows only the Track tab, so this is the way to last
          // session's numbers and the trend without leaving the workout.
          IconButton(
            tooltip: 'History & graph',
            icon: const Icon(Icons.query_stats),
            onPressed: () =>
                context.push('/exercise/${current.id}/${widget.dateStr}'),
          ),
        ],
      ),
      body: Column(
        children: [
          _ProgressBar(
            count: exercises.length,
            currentIndex: safeIndex,
            doneFlags: [
              for (final e in exercises) loggedIds.contains(e.$2.id),
            ],
            primary: primary,
            onTap: (i) => _goTo(i, exercises.length),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: exercises.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final cat = exercises[i].$2;
                return TrackTab(
                  key: ValueKey('session-${cat.id}'),
                  categoryId: cat.id,
                  dateStr: widget.dateStr,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: safeIndex == 0
                          ? null
                          : () => _goTo(safeIndex - 1, exercises.length),
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('PREV'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (isLast) {
                          context.pop();
                        } else {
                          _goTo(safeIndex + 1, exercises.length);
                        }
                      },
                      icon: Icon(
                          isLast ? Icons.check : Icons.chevron_right),
                      label: Text(isLast ? 'FINISH' : 'NEXT'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int count;
  final int currentIndex;
  final List<bool> doneFlags;
  final Color primary;
  final void Function(int) onTap;
  const _ProgressBar({
    required this.count,
    required this.currentIndex,
    required this.doneFlags,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: List.generate(count, (i) {
          final isCurrent = i == currentIndex;
          final isDone = doneFlags[i];
          final color = isCurrent
              ? primary
              : isDone
                  ? primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.15);
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
