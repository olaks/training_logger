import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home/home_screen.dart';
import 'screens/exercises/exercises_screen.dart';
import 'screens/detail/exercise_detail_screen.dart';
import 'screens/import/import_screen.dart';
import 'screens/plans/plans_screen.dart';
import 'screens/plans/plan_detail_screen.dart';
import 'screens/plans/workout_detail_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(path: '/',          builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/exercises', builder: (_, __) => const ExercisesScreen()),
        GoRoute(path: '/plans',     builder: (_, __) => const PlansScreen()),
      ],
    ),
    GoRoute(
      path: '/exercise/:id/:date',
      builder: (_, state) => ExerciseDetailScreen(
        categoryId: int.parse(state.pathParameters['id']!),
        dateStr:    state.pathParameters['date']!,
      ),
    ),
    GoRoute(
      path: '/workouts/:id',
      builder: (_, state) => WorkoutDetailScreen(
        workoutId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/plans/:id',
      builder: (_, state) => PlanDetailScreen(
        planId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/import',
      builder: (_, __) => const ImportScreen(),
    ),
  ],
);

class TrainingLoggerApp extends ConsumerWidget {
  const TrainingLoggerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(themeIndexProvider);
    return MaterialApp.router(
      title: 'Training Logger',
      theme: buildTheme(themeAccents[idx].color),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = loc.startsWith('/exercises')
        ? 1
        : loc.startsWith('/plans')
            ? 2
            : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/exercises');
          if (i == 2) context.go('/plans');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Exercises'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Plans'),
        ],
      ),
    );
  }
}
