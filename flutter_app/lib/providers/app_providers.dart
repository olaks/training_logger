import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../database/database.dart';
import '../utils/beeper.dart';
import '../utils/phase_countdown.dart';

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
    StreamProvider.family<ExerciseCategory?, int>((ref, id) =>
        ref.watch(dbProvider).watchCategoryById(id));

// ── Workouts ───────────────────────────────────────────────────────────────

final allWorkoutsProvider = StreamProvider<List<Workout>>((ref) =>
    ref.watch(dbProvider).watchAllWorkouts());

final workoutExercisesProvider =
    StreamProvider.family<List<(int, ExerciseCategory, int?, int?)>, int>((ref, workoutId) =>
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

// ── Exercise target for a date ────────────────────────────────────────────

final exerciseTargetProvider =
    StreamProvider.family<(int?, int?)?, ({int categoryId, String dateStr})>(
        (ref, p) => ref.watch(dbProvider).watchExerciseTarget(p.categoryId, p.dateStr));

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

// ── Inspirations ───────────────────────────────────────────────────────────

final inspirationsProvider =
    StreamProvider.family<List<Inspiration>, int?>((ref, categoryId) =>
        ref.watch(dbProvider).watchInspirations(categoryId: categoryId));

// ── Selected date (home screen) ────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ── TRACK tab stepper state ────────────────────────────────────────────────

class TrackState {
  final double weightKg;
  final int reps;
  final int timeSecs;
  final int rpe;        // 0 = not set, 1–10
  final int gradeIndex; // −1 = not set; index into grade scale list
  final int wallAngle;  // 0 = not set, in degrees
  final String climbName; // '' = not set
  const TrackState({
    this.weightKg = 0,
    this.reps = 0,
    this.timeSecs = 0,
    this.rpe = 0,
    this.gradeIndex = -1,
    this.wallAngle = 0,
    this.climbName = '',
  });

  TrackState copyWith({
    double? weightKg,
    int? reps,
    int? timeSecs,
    int? rpe,
    int? gradeIndex,
    int? wallAngle,
    String? climbName,
  }) => TrackState(
    weightKg:   weightKg   ?? this.weightKg,
    reps:       reps       ?? this.reps,
    timeSecs:   timeSecs   ?? this.timeSecs,
    rpe:        rpe        ?? this.rpe,
    gradeIndex: gradeIndex ?? this.gradeIndex,
    wallAngle:  wallAngle  ?? this.wallAngle,
    climbName:  climbName  ?? this.climbName,
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
  void incrementWallAngle() => state = state.copyWith(
      wallAngle: (state.wallAngle + 5).clamp(0, 90));
  void decrementWallAngle() => state = state.copyWith(
      wallAngle: (state.wallAngle - 5).clamp(0, 90));
  void setWallAngle(int v)  => state = state.copyWith(wallAngle: v.clamp(0, 90));
  void setClimbName(String v) => state = state.copyWith(climbName: v);
  void clear()              => state = const TrackState();
}

// keyed by categoryId so each exercise gets its own stepper state
final trackProvider = StateNotifierProvider.autoDispose
    .family<TrackNotifier, TrackState, int>(
  (ref, _) => TrackNotifier(),
);

// ── Rest timer (global, survives navigation) ─────────────────────────────

class RestTimerState {
  final bool active;
  final int remaining;
  final int restSecs; // chosen duration preset
  const RestTimerState({this.active = false, this.remaining = 0, this.restSecs = 180});
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  /// How long the finished panel stays up before it dismisses itself.
  static const _completedHoldSecs = 3;

  /// A tick that lands this late means the timer was throttled while the app
  /// was in the background — the rest is long over, so don't beep about it.
  static const _staleFinishMs = 2000;

  late final PhaseCountdown _countdown;
  Timer? _dismissTimer;
  Beeper? _beeper;

  /// Sound, haptics and the wakelock all need platform plugins; tests turn
  /// them off to exercise the countdown itself.
  final bool _withFeedback;

  RestTimerNotifier({bool withFeedback = true})
      : _withFeedback = withFeedback,
        super(const RestTimerState()) {
    _countdown = PhaseCountdown(
      onChanged: _publish,
      onElapsed: _finish,
      onFinalSeconds: (_) {
        _beeper?.tick();
        if (_withFeedback) HapticFeedback.lightImpact();
      },
    );
  }

  void start() => _run(state.restSecs);

  void setDurationAndRestart(int secs) => _run(secs);

  void _run(int secs) {
    _dismissTimer?.cancel();
    if (_withFeedback) {
      _beeper ??= Beeper();
      WakelockPlus.enable();
    }
    _countdown.start(secs);
    state = RestTimerState(active: true, remaining: secs, restSecs: secs);
  }

  void cancel() {
    _dismissTimer?.cancel();
    _countdown.stop();
    _releaseWakelock();
    state = RestTimerState(active: false, remaining: 0, restSecs: state.restSecs);
  }

  void _releaseWakelock() {
    if (_withFeedback) WakelockPlus.disable();
  }

  /// Ticks come ten times a second; only whole seconds are worth publishing.
  void _publish() {
    final secsLeft = _countdown.remainingSecs;
    if (secsLeft != state.remaining) {
      state = RestTimerState(
          active: true, remaining: secsLeft, restSecs: state.restSecs);
    }
  }

  void _finish(int overshootMs) {
    _countdown.stop();
    _releaseWakelock();
    if (overshootMs < _staleFinishMs) {
      _beeper?.done();
      if (_withFeedback) HapticFeedback.heavyImpact();
    }
    state = RestTimerState(
        active: true, remaining: 0, restSecs: state.restSecs);
    _dismissTimer = Timer(const Duration(seconds: _completedHoldSecs), () {
      state = RestTimerState(
          active: false, remaining: 0, restSecs: state.restSecs);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _countdown.dispose();
    _beeper?.dispose();
    if (state.active) _releaseWakelock();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>(
    (ref) => RestTimerNotifier());

// ── Database mutation helpers ──────────────────────────────────────────────

extension DbMutations on WidgetRef {
  AppDatabase get db => read(dbProvider);

  Future<void> addCategory(String name, {String? groupName, String? description}) =>
      db.insertOrGetCategory(name, groupName: groupName, description: description);
  Future<void> renameCategory(int id, String name) => db.renameCategory(id, name);
  Future<void> updateCategoryGroup(int id, String? group) => db.updateCategoryGroup(id, group);
  Future<void> updateCategoryDescription(int id, String? description) =>
      db.updateCategoryDescription(id, description);
  Future<DeletedCategory?> removeCategory(int id)  => db.deleteCategory(id);
  Future<void> restoreCategory(DeletedCategory d)  => db.restoreCategory(d);

  /// Pass [grade] for climbing exercises (only grade + rpe are stored).
  Future<void> saveSet({
    required int categoryId,
    required String dateStr,
    required TrackState state,
    String? grade,
  }) {
    final e = state.rpe > 0 ? state.rpe : null;
    if (grade != null) {
      final angle = state.wallAngle > 0 ? state.wallAngle : null;
      final trimmedName = state.climbName.trim();
      final name = trimmedName.isEmpty ? null : trimmedName;
      return db.insertSet(WorkoutSetsCompanion.insert(
        categoryId: categoryId,
        dateStr:    dateStr,
        timestamp:  DateTime.now().millisecondsSinceEpoch,
        grade:      Value(grade),
        rpe:        Value(e),
        wallAngle:  Value(angle),
        climbName:  Value(name),
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

  Future<WorkoutSet?> removeSet(int id) => db.deleteSet(id);
  Future<void> restoreSet(WorkoutSet set) => db.restoreSet(set);

  /// Writes a corrected version of an already-logged set. Empty values are
  /// cleared rather than kept, so the set ends up as what the sheet shows.
  Future<void> editSet(
    int id, {
    double? weightKg,
    int? reps,
    int? timeSecs,
    int? rpe,
    String? grade,
    int? wallAngle,
    String? climbName,
  }) =>
      db.updateSet(
        id,
        weightKg:  weightKg,
        reps:      reps,
        timeSecs:  timeSecs,
        rpe:       rpe,
        grade:     grade,
        wallAngle: wallAngle,
        climbName: climbName,
      );

  Future<void> saveCategoryImage(int id, Uint8List? data) =>
      db.updateCategoryImage(id, data);

  Future<void> setExerciseType(int id, int type) => db.setExerciseType(id, type);

  // Workouts
  Future<int>  insertWorkout(String name)                     => db.insertWorkout(name);
  Future<int>  duplicateWorkout(int id, {String? newName})    => db.duplicateWorkout(id, newName: newName);
  Future<int>  createWorkoutFromDay(String dateStr, String name) =>
      db.createWorkoutFromDay(dateStr, name);
  Future<String> uniqueWorkoutName(String base)               => db.uniqueWorkoutName(base);
  Future<int>  renameWorkout(int id, String name)             => db.renameWorkout(id, name);
  Future<int>  updateWorkoutNotes(int id, String notes)      => db.updateWorkoutNotes(id, notes);
  Future<void> reorderWorkoutExercises(int wId, List<int> weIds) => db.reorderWorkoutExercises(wId, weIds);
  Future<DeletedWorkout?> deleteWorkout(int id)               => db.deleteWorkout(id);
  Future<void> restoreWorkout(DeletedWorkout d)               => db.restoreWorkout(d);
  Future<void> addExerciseToWorkout(int workoutId, int catId) => db.addExerciseToWorkout(workoutId, catId);
  Future<int>  removeExerciseFromWorkout(int weId)            => db.removeExerciseFromWorkout(weId);
  Future<int>  removeAllOfExerciseFromWorkout(int wId, int catId) => db.removeAllOfExerciseFromWorkout(wId, catId);
  Future<int>  updateWorkoutTarget(int weId, int? sets, int? reps) =>
      db.updateWorkoutTarget(weId, sets, reps);

  // Inspirations
  Future<int> addInspiration({
    required String title,
    required String url,
    String? notes,
    int? categoryId,
  }) =>
      db.insertInspiration(
          title: title, url: url, notes: notes, categoryId: categoryId);

  Future<int> editInspiration(
    int id, {
    required String title,
    required String url,
    String? notes,
    int? categoryId,
  }) =>
      db.updateInspiration(id,
          title: title, url: url, notes: notes, categoryId: categoryId);

  Future<int> removeInspiration(int id) => db.deleteInspiration(id);

  // Plans
  Future<int>  insertPlan(String name)              => db.insertPlan(name);
  Future<int>  importPlanFromJson(String jsonStr)   => db.importPlanFromJson(jsonStr);
  Future<int>  renamePlan(int id, String name)      => db.renamePlan(id, name);
  Future<DeletedPlan?> deletePlan(int id)           => db.deletePlan(id);
  Future<void> restorePlan(DeletedPlan d)           => db.restorePlan(d);
  Future<int>  assignWorkoutToPlan(int planId, int workoutId, {int? weekday, String? dateStr}) =>
      db.assignWorkoutToPlan(planId, workoutId, weekday: weekday, dateStr: dateStr);
  Future<int>  removeWorkoutFromPlan(int assignmentId) => db.removeWorkoutFromPlan(assignmentId);
  Future<void> shiftPlanDay(int planId, int weekday) => db.shiftPlanDay(planId, weekday);
  Future<void> shiftPlanWeekFrom(int planId, int fromWeekday) =>
      db.shiftPlanWeekFrom(planId, fromWeekday);
}
