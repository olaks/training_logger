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

// ── Workouts ───────────────────────────────────────────────────────────────

final allWorkoutsProvider = StreamProvider<List<Workout>>((ref) =>
    ref.watch(dbProvider).watchAllWorkouts());

final workoutExercisesProvider =
    StreamProvider.family<List<(ExerciseCategory, int?, int?)>, int>((ref, workoutId) =>
        ref.watch(dbProvider).watchExercisesForWorkout(workoutId));

final workoutsForExerciseProvider =
    StreamProvider.family<List<Workout>, int>((ref, categoryId) =>
        ref.watch(dbProvider).watchWorkoutsForExercise(categoryId));

// ── Plans ──────────────────────────────────────────────────────────────────

final allPlansProvider = StreamProvider<List<Plan>>((ref) =>
    ref.watch(dbProvider).watchAllPlans());

final planWorkoutsProvider =
    StreamProvider.family<List<PlanWorkout>, int>((ref, planId) =>
        ref.watch(dbProvider).watchPlanWorkouts(planId));

final plannedCategoryIdsProvider =
    StreamProvider.family<Set<int>, String>((ref, dateStr) =>
        ref.watch(dbProvider).watchPlannedCategoryIdsForDate(dateStr));

final plannedWorkoutsForDateProvider =
    StreamProvider.family<List<(Workout, List<ExerciseCategory>)>, String>(
        (ref, dateStr) =>
            ref.watch(dbProvider).watchPlannedWorkoutsForDate(dateStr));

// ── Day notes ─────────────────────────────────────────────────────────────

final dayNoteProvider =
    StreamProvider.family<DayNote?, String>((ref, dateStr) =>
        ref.watch(dbProvider).watchDayNote(dateStr));

// ── Body weight ────────────────────────────────────────────────────────────

final bodyWeightsProvider = StreamProvider<List<BodyWeight>>((ref) =>
    ref.watch(dbProvider).watchBodyWeights());

final bodyWeightForDateProvider =
    StreamProvider.family<BodyWeight?, String>((ref, dateStr) =>
        ref.watch(dbProvider).watchBodyWeightForDate(dateStr));

// ── Selected date (home screen) ────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ── TRACK tab stepper state ────────────────────────────────────────────────

class TrackState {
  final double weightKg;
  final int reps;
  final int timeSecs;
  final int rpe;        // 0 = not set, 1–10
  final int gradeIndex; // −1 = not set; index into grade scale list
  const TrackState({
    this.weightKg = 0,
    this.reps = 0,
    this.timeSecs = 0,
    this.rpe = 0,
    this.gradeIndex = -1,
  });

  TrackState copyWith({
    double? weightKg,
    int? reps,
    int? timeSecs,
    int? rpe,
    int? gradeIndex,
  }) => TrackState(
    weightKg:   weightKg   ?? this.weightKg,
    reps:       reps       ?? this.reps,
    timeSecs:   timeSecs   ?? this.timeSecs,
    rpe:        rpe        ?? this.rpe,
    gradeIndex: gradeIndex ?? this.gradeIndex,
  );
}

class TrackNotifier extends StateNotifier<TrackState> {
  TrackNotifier() : super(const TrackState());

  void incrementWeight() => state = state.copyWith(weightKg: (state.weightKg + 1).clamp(-500, 999).toDouble());
  void decrementWeight() => state = state.copyWith(weightKg: (state.weightKg - 1).clamp(-500, 999).toDouble());
  void incrementReps()   => state = state.copyWith(reps: (state.reps + 1).clamp(0, 999));
  void decrementReps()   => state = state.copyWith(reps: (state.reps - 1).clamp(0, 999));
  void incrementTime()   => state = state.copyWith(timeSecs: (state.timeSecs + 5).clamp(0, 36000));
  void decrementTime()   => state = state.copyWith(timeSecs: (state.timeSecs - 5).clamp(0, 36000));
  void setWeight(double v) => state = state.copyWith(weightKg: v.clamp(-500.0, 999.0));
  void setReps(int v)      => state = state.copyWith(reps: v.clamp(0, 999));
  void setTimeSecs(int v)  => state = state.copyWith(timeSecs: v.clamp(0, 36000));
  void setRpe(int v)       => state = state.copyWith(rpe: v.clamp(0, 10));
  // Grade: −1 = none, 0…n = index in scale list
  void incrementGrade(int max) => state = state.copyWith(
      gradeIndex: (state.gradeIndex + 1).clamp(0, max));
  void decrementGrade() => state = state.copyWith(
      gradeIndex: (state.gradeIndex - 1).clamp(-1, 999));
  void setGradeIndex(int v) => state = state.copyWith(gradeIndex: v.clamp(-1, 999));
  void clear()              => state = const TrackState();
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
      db.insertOrGetCategory(name, groupName: groupName);
  Future<void> renameCategory(int id, String name) => db.renameCategory(id, name);
  Future<void> updateCategoryGroup(int id, String? group) => db.updateCategoryGroup(id, group);
  Future<void> removeCategory(int id)              => db.deleteCategory(id);

  /// Pass [grade] for climbing exercises (only grade + rpe are stored).
  Future<void> saveSet({
    required int categoryId,
    required String dateStr,
    required TrackState state,
    String? grade,
  }) {
    final e = state.rpe > 0 ? state.rpe : null;
    if (grade != null) {
      return db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: categoryId,
        dateStr:    dateStr,
        timestamp:  DateTime.now().millisecondsSinceEpoch,
        grade:      Value(grade),
        rpe:        Value(e),
      ));
    }
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
      rpe:        Value(e),
    ));
  }

  Future<void> saveDayNote(String dateStr, String note) =>
      db.saveDayNote(dateStr, note);
  Future<void> deleteDayNote(String dateStr) => db.deleteDayNote(dateStr);

  Future<void> saveBodyWeight(String dateStr, double kg) =>
      db.saveBodyWeight(dateStr, kg);
  Future<void> deleteBodyWeight(String dateStr) => db.deleteBodyWeight(dateStr);

  Future<void> removeSet(int id) => db.deleteSet(id);

  Future<void> saveCategoryImage(int id, Uint8List? data) =>
      db.updateCategoryImage(id, data);

  Future<void> setExerciseType(int id, int type) => db.setExerciseType(id, type);

  // Workouts
  Future<int>  insertWorkout(String name)                     => db.insertWorkout(name);
  Future<int>  renameWorkout(int id, String name)             => db.renameWorkout(id, name);
  Future<void> deleteWorkout(int id)                          => db.deleteWorkout(id);
  Future<void> addExerciseToWorkout(int workoutId, int catId) => db.addExerciseToWorkout(workoutId, catId);
  Future<int>  removeExerciseFromWorkout(int wId, int catId)  => db.removeExerciseFromWorkout(wId, catId);
  Future<int>  updateWorkoutTarget(int wId, int catId, int? sets, int? reps) =>
      db.updateWorkoutTarget(wId, catId, sets, reps);

  // Plans
  Future<int>  insertPlan(String name)              => db.insertPlan(name);
  Future<int>  renamePlan(int id, String name)      => db.renamePlan(id, name);
  Future<void> deletePlan(int id)                   => db.deletePlan(id);
  Future<int>  assignWorkoutToPlan(int planId, int workoutId, {int? weekday, String? dateStr}) =>
      db.assignWorkoutToPlan(planId, workoutId, weekday: weekday, dateStr: dateStr);
  Future<int>  removeWorkoutFromPlan(int assignmentId) => db.removeWorkoutFromPlan(assignmentId);
}
