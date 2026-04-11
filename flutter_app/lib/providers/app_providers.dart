import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../database/database.dart';

// ── Database singleton ─────────────────────────────────────────────────────

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── Streams ────────────────────────────────────────────────────────────────

final categoriesProvider = StreamProvider<List<ExerciseCategory>>((ref) =>
    ref.watch(dbProvider).watchAllCategories());

final workoutDatesProvider = StreamProvider<List<String>>((ref) =>
    ref.watch(dbProvider).watchWorkoutDates());

final setsForDayProvider =
    StreamProvider.family<List<WorkoutSet>, String>((ref, dateStr) =>
        ref.watch(dbProvider).watchSetsForDay(dateStr));

final setsForCategoryProvider =
    StreamProvider.family<List<WorkoutSet>, int>((ref, categoryId) =>
        ref.watch(dbProvider).watchSetsForCategory(categoryId));

final categoryByIdProvider =
    FutureProvider.family<ExerciseCategory?, int>((ref, id) =>
        ref.watch(dbProvider).getCategoryById(id));

// ── Selected date (home screen) ────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ── TRACK tab stepper state ────────────────────────────────────────────────

class TrackState {
  final double weightKg;
  final int reps;
  final int timeSecs;
  const TrackState({this.weightKg = 0, this.reps = 0, this.timeSecs = 0});

  TrackState copyWith({double? weightKg, int? reps, int? timeSecs}) => TrackState(
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        timeSecs: timeSecs ?? this.timeSecs,
      );
}

class TrackNotifier extends StateNotifier<TrackState> {
  TrackNotifier() : super(const TrackState());

  void incrementWeight() => state = state.copyWith(weightKg: (state.weightKg + 1).clamp(-500, 999));
  void decrementWeight() => state = state.copyWith(weightKg: (state.weightKg - 1).clamp(-500, 999));
  void incrementReps()   => state = state.copyWith(reps: (state.reps + 1).clamp(0, 999));
  void decrementReps()   => state = state.copyWith(reps: (state.reps - 1).clamp(0, 999));
  void incrementTime()   => state = state.copyWith(timeSecs: (state.timeSecs + 5).clamp(0, 36000));
  void decrementTime()   => state = state.copyWith(timeSecs: (state.timeSecs - 5).clamp(0, 36000));
  void clear()           => state = const TrackState();
}

// keyed by categoryId so each exercise gets its own stepper state
final trackProvider = StateNotifierProvider.autoDispose
    .family<TrackNotifier, TrackState, int>(
  (ref, _) => TrackNotifier(),
);

// ── Database mutation helpers ──────────────────────────────────────────────

extension DbMutations on WidgetRef {
  AppDatabase get db => read(dbProvider);

  Future<void> addCategory(String name, {String? groupName}) =>
      db.insertCategory(name, groupName: groupName);
  Future<void> renameCategory(int id, String name) => db.renameCategory(id, name);
  Future<void> updateCategoryGroup(int id, String? group) => db.updateCategoryGroup(id, group);
  Future<void> removeCategory(int id)              => db.deleteCategory(id);

  Future<void> saveSet({
    required int categoryId,
    required String dateStr,
    required TrackState state,
  }) {
    final w = state.weightKg != 0 ? state.weightKg : null;
    final r = state.reps > 0     ? state.reps     : null;
    final t = state.timeSecs > 0 ? state.timeSecs : null;
    if (w == null && r == null && t == null) return Future.value();
    return db.insertSet(WorkoutSetsCompanion.insert(
      categoryId: categoryId,
      dateStr:    dateStr,
      timestamp:  DateTime.now().millisecondsSinceEpoch,
      weightKg:   Value(w),
      reps:       Value(r),
      timeSecs:   Value(t),
    ));
  }

  Future<void> removeSet(int id) => db.deleteSet(id);

  Future<void> saveCategoryImage(int id, Uint8List? data) =>
      db.updateCategoryImage(id, data);
}
