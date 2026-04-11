import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../database/database.dart';
import '../../providers/app_providers.dart';
import '../../utils/format_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected    = ref.watch(selectedDateProvider);
    final dateStr     = dateStrFrom(selected);
    final setsAsync   = ref.watch(setsForDayProvider(dateStr));
    final cats        = ref.watch(categoriesProvider).value ?? [];
    final woDates     = ref.watch(workoutDatesProvider).value ?? [];
    final plannedIds  = ref.watch(plannedCategoryIdsProvider(dateStr)).value ?? <int>{};

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _DayNavBar(
              selected: selected,
              onPrev: () => ref.read(selectedDateProvider.notifier).state =
                  selected.subtract(const Duration(days: 1)),
              onNext: () => ref.read(selectedDateProvider.notifier).state =
                  selected.add(const Duration(days: 1)),
              onCalendar: () => _openCalendar(context, ref, selected, woDates),
            ),
          ),
          Expanded(
            child: setsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (sets) {
                final grouped = <int, List<WorkoutSet>>{};
                for (final s in sets) {
                  grouped.putIfAbsent(s.categoryId, () => []).add(s);
                }
                // Union of logged exercises and plan-scheduled exercises
                final allIds = <int>{...grouped.keys, ...plannedIds};
                if (allIds.isEmpty) {
                  return _EmptyState(onStart: () => context.go('/exercises'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: allIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final catId = allIds.elementAt(i);
                    final name  = cats.firstWhere((c) => c.id == catId,
                        orElse: () => ExerciseCategory(id: catId, name: 'Unknown')).name;
                    return _DayExerciseCard(
                      name:  name,
                      sets:  grouped[catId] ?? [],
                      onTap: () => context.push('/exercise/$catId/$dateStr'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/exercises'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selected,
    List<String> woDates,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _CalendarSheet(
        selected:     selected,
        workoutDates: woDates.toSet(),
        onSelected: (date) {
          ref.read(selectedDateProvider.notifier).state = date;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Day nav bar ────────────────────────────────────────────────────────────

class _DayNavBar extends StatelessWidget {
  final DateTime selected;
  final VoidCallback onPrev, onNext, onCalendar;
  const _DayNavBar(
      {required this.selected,
      required this.onPrev,
      required this.onNext,
      required this.onCalendar});

  String get _label {
    final now = DateTime.now();
    if (isSameDay(selected, now)) return 'TODAY';
    if (isSameDay(selected, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
    if (isSameDay(selected, now.add(const Duration(days: 1)))) return 'TOMORROW';
    return DateFormat('EEE, MMM d').format(selected).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: GestureDetector(
              onTap: onCalendar,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_label,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(width: 6),
                  Icon(Icons.calendar_month,
                      size: 17, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 72, color: Colors.white.withValues(alpha:0.1)),
            const SizedBox(height: 16),
            Text('Workout Log Empty',
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withValues(alpha:0.35))),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add),
              label: const Text('Start New Workout'),
            ),
          ],
        ),
      );
}

// ── Exercise summary card ───────────────────────────────────────────────────

class _DayExerciseCard extends StatelessWidget {
  final String name;
  final List<WorkoutSet> sets;
  final VoidCallback onTap;
  const _DayExerciseCard(
      {required this.name, required this.sets, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      '${sets.length} set${sets.length != 1 ? "s" : ""}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...sets.asMap().entries.map((e) => Text(
                      '  Set ${e.key + 1}:  ${formatSet(weightKg: e.value.weightKg, reps: e.value.reps, timeSecs: e.value.timeSecs)}',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha:0.55)),
                    )),
              ],
            ),
          ),
        ),
      );
}

// ── Calendar bottom sheet ───────────────────────────────────────────────────

class _CalendarSheet extends StatefulWidget {
  final DateTime selected;
  final Set<String> workoutDates;
  final ValueChanged<DateTime> onSelected;
  const _CalendarSheet(
      {required this.selected,
      required this.workoutDates,
      required this.onSelected});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focused;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _focused  = widget.selected;
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay:  DateTime(2020),
          lastDay:   DateTime(2030),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            final s = dateStrFrom(day);
            return widget.workoutDates.contains(s) ? [s] : [];
          },
          onDaySelected: (sel, foc) {
            setState(() {
              _selected = sel;
              _focused  = foc;
            });
            widget.onSelected(sel);
          },
          onPageChanged: (foc) => setState(() => _focused = foc),
        ),
      );
}
