import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';
import '../utils/format_utils.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Workouts, WorkoutExercises, Plans, PlanWorkouts, ExerciseCategories, WorkoutSets, DayNotes, BodyWeights])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(
    name: 'training_logger',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ));

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(exerciseCategories, exerciseCategories.imageData);
      }
      if (from < 3) {
        await m.addColumn(exerciseCategories, exerciseCategories.groupName);
      }
      // from < 4: old v4 tables are superseded — handled in from < 5 below
      if (from < 5) {
        await customStatement('DROP TABLE IF EXISTS plan_exercises');
        await customStatement('DROP TABLE IF EXISTS scheduled_plans');
        await customStatement('DROP TABLE IF EXISTS plans');
        await m.createTable(workouts);
        await m.createTable(workoutExercises);
        await m.createTable(plans);
        await m.createTable(planWorkouts);
      }
      if (from >= 5 && from < 6) {
        await m.addColumn(workoutExercises, workoutExercises.targetReps);
      }
      if (from < 7) {
        await m.addColumn(workoutSets, workoutSets.rpe);
        await m.createTable(dayNotes);
        await m.createTable(bodyWeights);
      }
      if (from < 8) {
        await m.addColumn(exerciseCategories, exerciseCategories.exerciseType);
        await m.addColumn(workoutSets, workoutSets.grade);
      }
      if (from < 9) {
        // Insert Bouldering exercises if not already present (case-insensitive)
        const bouldering = [
          ('Max Boulder',  'Bouldering', 1),
          ('Flash',        'Bouldering', 1),
          ('Onsight',      'Bouldering', 1),
          ('Moonboard',    'Bouldering', 1),
          ('Kilter Board', 'Bouldering', 1),
        ];
        for (final (name, group, type) in bouldering) {
          final existing = await (select(exerciseCategories)
                ..where((t) => t.name.like(name)))
              .get();
          final found = existing.any(
              (c) => c.name.toLowerCase() == name.toLowerCase());
          if (!found) {
            await into(exerciseCategories).insert(
              ExerciseCategoriesCompanion.insert(
                name:         name,
                groupName:    Value(group),
                exerciseType: Value(type),
              ),
            );
          }
        }
      }
      if (from < 10) {
        await m.addColumn(workoutExercises, workoutExercises.targetSets);
      }
    },
  );

  Future<void> _seedDefaults() async {
    // (name, group, exerciseType)  0=standard  1=climbing
    const defaults = [
      // Bouldering — grade-based, exerciseType=1
      ('Max Boulder',              'Bouldering',       1),
      ('Flash',                    'Bouldering',       1),
      ('Onsight',                  'Bouldering',       1),
      ('Moonboard',                'Bouldering',       1),
      ('Kilter Board',             'Bouldering',       1),
      // Finger Strength
      ('Dead Hang',                'Finger Strength',  0),
      ('One-Arm Hang',             'Finger Strength',  0),
      ('Tension Block 15 mm',      'Finger Strength',  0),
      ('Tension Block 20 mm',      'Finger Strength',  0),
      ('Nature Board 15 mm',       'Finger Strength',  0),
      ('Nature Board 20 mm',       'Finger Strength',  0),
      // Power
      ('Campus Rungs',             'Power',            0),
      ('Double Dynos',             'Power',            0),
      ('Explosive Pull Up',        'Power',            0),
      // Power Endurance
      ('4×4 Bouldering',          'Power Endurance',  0),
      ('Linked Boulder Circuit',   'Power Endurance',  0),
      // Endurance
      ('ARC Traversing',           'Endurance',        0),
      ('Continuous Climbing',      'Endurance',        0),
      // Movement
      ('Footwork Drills',          'Movement',         0),
      ('Slab Technique',           'Movement',         0),
      // Antagonist
      ('Wrist Extension',          'Antagonist',       0),
      ('Rotator Cuff',             'Antagonist',       0),
      ('Push Up',                  'Antagonist',       0),
      ('Reverse Curl',             'Antagonist',       0),
      // General Strength
      ('Pull Up',                  'General Strength', 0),
      ('Lat Pulldown',             'General Strength', 0),
      ('One-Arm Pull Up',          'General Strength', 0),
      ('Deadlift',                 'General Strength', 0),
      // Core
      ('Front Lever',              'Core',             0),
      ('Hollow Body Hold',         'Core',             0),
      ('Hanging Leg Raise',        'Core',             0),
    ];
    await batch((b) {
      for (final (name, group, type) in defaults) {
        b.insert(exerciseCategories, ExerciseCategoriesCompanion.insert(
          name:         name,
          groupName:    Value(group),
          exerciseType: Value(type),
        ));
      }
    });
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Stream<List<ExerciseCategory>> watchAllCategories() =>
      (select(exerciseCategories)
            ..orderBy([
              (t) => OrderingTerm.asc(t.groupName),
              (t) => OrderingTerm.asc(t.name),
            ]))
          .watch();

  Future<ExerciseCategory?> getCategoryById(int id) =>
      (select(exerciseCategories)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertCategory(String name, {String? groupName}) =>
      into(exerciseCategories).insert(ExerciseCategoriesCompanion.insert(
        name: name,
        groupName: Value(groupName),
      ));

  /// Returns existing category id if name matches (case-insensitive),
  /// otherwise inserts a new one.
  Future<int> insertOrGetCategory(String name, {String? groupName}) async {
    final existing = await (select(exerciseCategories)
          ..where((t) => t.name.like(name)))
        .get();
    final match = existing
        .where((c) => c.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (match != null) return match.id;
    return insertCategory(name, groupName: groupName);
  }

  Future<int> renameCategory(int id, String name) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(name: Value(name)));

  Future<int> updateCategoryGroup(int id, String? groupName) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(groupName: Value(groupName)));

  Future<int> deleteCategory(int id) =>
      (delete(exerciseCategories)..where((t) => t.id.equals(id))).go();

  Future<int> updateCategoryImage(int id, Uint8List? data) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(imageData: Value(data)));

  Future<int> setExerciseType(int id, int type) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(exerciseType: Value(type)));

  // ── Workout sets ──────────────────────────────────────────────────────────

  Stream<List<WorkoutSet>> watchSetsForDay(String dateStr) =>
      (select(workoutSets)
            ..where((t) => t.dateStr.equals(dateStr))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .watch();

  Stream<List<WorkoutSet>> watchSetsForCategory(int categoryId) =>
      (select(workoutSets)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.dateStr),
              (t) => OrderingTerm.asc(t.timestamp),
            ]))
          .watch();

  Stream<List<String>> watchWorkoutDates() => customSelect(
        'SELECT DISTINCT date_str FROM workout_sets ORDER BY date_str ASC',
        readsFrom: {workoutSets},
      ).map((row) => row.read<String>('date_str')).watch();

  Future<int> insertSet(WorkoutSetsCompanion set) =>
      into(workoutSets).insert(set);

  Future<int> deleteSet(int id) =>
      (delete(workoutSets)..where((t) => t.id.equals(id))).go();

  // ── Day notes ─────────────────────────────────────────────────────────────

  Stream<DayNote?> watchDayNote(String dateStr) =>
      (select(dayNotes)..where((t) => t.dateStr.equals(dateStr)))
          .watchSingleOrNull();

  Future<void> saveDayNote(String dateStr, String note) =>
      into(dayNotes).insertOnConflictUpdate(
          DayNotesCompanion.insert(dateStr: dateStr, note: note));

  Future<void> deleteDayNote(String dateStr) =>
      (delete(dayNotes)..where((t) => t.dateStr.equals(dateStr))).go();

  // ── Body weight log ───────────────────────────────────────────────────────

  Stream<List<BodyWeight>> watchBodyWeights() =>
      (select(bodyWeights)
            ..orderBy([(t) => OrderingTerm.asc(t.dateStr)]))
          .watch();

  Stream<BodyWeight?> watchBodyWeightForDate(String dateStr) =>
      (select(bodyWeights)..where((t) => t.dateStr.equals(dateStr)))
          .watchSingleOrNull();

  Future<void> saveBodyWeight(String dateStr, double kg) =>
      into(bodyWeights).insertOnConflictUpdate(
          BodyWeightsCompanion.insert(dateStr: dateStr, kg: kg));

  Future<void> deleteBodyWeight(String dateStr) =>
      (delete(bodyWeights)..where((t) => t.dateStr.equals(dateStr))).go();

  // ── Export plan ───────────────────────────────────────────────────────────

  Future<String> exportPlanToJson(int planId) async {
    final plan = await (select(plans)..where((t) => t.id.equals(planId)))
        .getSingleOrNull();
    if (plan == null) throw StateError('Plan $planId not found');

    final assignments =
        await (select(planWorkouts)..where((t) => t.planId.equals(planId))).get();
    final workoutIds = assignments.map((a) => a.workoutId).toSet().toList();

    final planWorkoutsList = await (select(workouts)
          ..where((t) => t.id.isIn(workoutIds))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    final workoutById = {for (final w in planWorkoutsList) w.id: w};

    final workoutsJson = <Map<String, dynamic>>[];
    for (final workout in planWorkoutsList) {
      final q = select(workoutExercises).join([
        innerJoin(exerciseCategories,
            exerciseCategories.id.equalsExp(workoutExercises.categoryId)),
      ])
        ..where(workoutExercises.workoutId.equals(workout.id))
        ..orderBy([OrderingTerm.asc(exerciseCategories.name)]);
      final rows = await q.get();

      workoutsJson.add({
        'name': workout.name,
        'exercises': rows.map((row) {
          final we = row.readTable(workoutExercises);
          final ec = row.readTable(exerciseCategories);
          return <String, dynamic>{
            'name': ec.name,
            if (ec.groupName  != null) 'group':      ec.groupName,
            if (we.targetSets != null) 'targetSets': we.targetSets,
            if (we.targetReps != null) 'targetReps': we.targetReps,
          };
        }).toList(),
      });
    }

    final assignmentsJson = assignments.map((a) => <String, dynamic>{
          'workout': workoutById[a.workoutId]?.name ?? '',
          if (a.weekday != null) 'weekday': a.weekday,
          if (a.dateStr != null) 'date':    a.dateStr,
        }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'version':    1,
      'exportedAt': DateTime.now().toIso8601String(),
      'plan': {
        'name':        plan.name,
        'workouts':    workoutsJson,
        'assignments': assignmentsJson,
      },
    });
  }

  // ── Export / Import backup ────────────────────────────────────────────────

  Future<String> exportToJson() async {
    final cats    = await select(exerciseCategories).get();
    final allSets = await select(workoutSets).get();

    final setsByCategory = <int, List<WorkoutSet>>{};
    for (final s in allSets) {
      setsByCategory.putIfAbsent(s.categoryId, () => []).add(s);
    }

    final exercises = cats.map((cat) {
      final sets = (setsByCategory[cat.id] ?? []).map((s) => {
        'date':      s.dateStr,
        'timestamp': s.timestamp,
        if (s.weightKg != null) 'weightKg':  s.weightKg,
        if (s.reps     != null) 'reps':      s.reps,
        if (s.timeSecs != null) 'timeSecs':  s.timeSecs,
      }).toList();

      return <String, dynamic>{
        'name': cat.name,
        if (cat.groupName  != null) 'group': cat.groupName,
        if (cat.imageData  != null) 'image': base64.encode(cat.imageData!),
        'sets': sets,
      };
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'version':    1,
      'exportedAt': DateTime.now().toIso8601String(),
      'exercises':  exercises,
    });
  }

  Future<int> importFromJson(String jsonStr) async {
    final data      = jsonDecode(jsonStr) as Map<String, dynamic>;
    final exercises = (data['exercises'] as List).cast<Map<String, dynamic>>();
    int inserted    = 0;

    await transaction(() async {
      for (final ex in exercises) {
        final name     = ex['name']  as String;
        final group    = ex['group'] as String?;
        final imageB64 = ex['image'] as String?;

        int catId;
        final existing = await (select(exerciseCategories)
              ..where((t) => t.name.equals(name)))
            .getSingleOrNull();

        if (existing == null) {
          catId = await insertCategory(name, groupName: group);
          if (imageB64 != null) {
            await updateCategoryImage(catId, base64.decode(imageB64));
          }
        } else {
          catId = existing.id;
          final patch = ExerciseCategoriesCompanion(
            groupName: existing.groupName == null && group != null
                ? Value(group)
                : const Value.absent(),
            imageData: existing.imageData == null && imageB64 != null
                ? Value(base64.decode(imageB64))
                : const Value.absent(),
          );
          if (patch.groupName.present || patch.imageData.present) {
            await (update(exerciseCategories)
                  ..where((t) => t.id.equals(catId)))
                .write(patch);
          }
        }

        for (final s in (ex['sets'] as List).cast<Map<String, dynamic>>()) {
          final ts = s['timestamp'] as int;
          final dup = await (select(workoutSets)
                ..where((t) =>
                    t.categoryId.equals(catId) & t.timestamp.equals(ts)))
              .getSingleOrNull();
          if (dup != null) continue;

          await into(workoutSets).insert(WorkoutSetsCompanion.insert(
            categoryId: catId,
            dateStr:    s['date'] as String,
            timestamp:  ts,
            weightKg:   Value((s['weightKg'] as num?)?.toDouble()),
            reps:       Value((s['reps']     as num?)?.toInt()),
            timeSecs:   Value((s['timeSecs'] as num?)?.toInt()),
          ));
          inserted++;
        }
      }
    });
    return inserted;
  }

  // ── Import FitNotes CSV ───────────────────────────────────────────────────

  Future<int> importFitNotes(List<Map<String, String>> rows) async {
    int inserted = 0;
    await transaction(() async {
      final cache = <String, int>{};

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final exerciseName = row['Exercise'] ?? '';
        if (exerciseName.isEmpty) continue;

        final groupName = _nullIfEmpty(row['Category']);
        final dateStr   = row['Date'] ?? '';
        if (dateStr.isEmpty) continue;

        double? weightKg;
        final wStr  = row['Weight'] ?? '';
        final wUnit = (row['Weight Unit'] ?? '').toLowerCase();
        if (wStr.isNotEmpty) {
          final w = double.tryParse(wStr);
          if (w != null && w > 0) {
            weightKg = wUnit == 'lbs' ? w / 2.20462 : w;
          }
        }

        int? reps;
        final rStr = row['Reps'] ?? '';
        if (rStr.isNotEmpty) {
          final r = int.tryParse(rStr);
          if (r != null && r > 0) reps = r;
        }

        int? timeSecs;
        final tStr = row['Time'] ?? '';
        if (tStr.isNotEmpty) {
          timeSecs = _parseTime(tStr);
        }

        if (weightKg == null && reps == null && timeSecs == null) continue;

        if (!cache.containsKey(exerciseName)) {
          final existing = await (select(exerciseCategories)
                ..where((t) => t.name.equals(exerciseName)))
              .getSingleOrNull();
          if (existing != null) {
            cache[exerciseName] = existing.id;
            if (existing.groupName == null && groupName != null) {
              await (update(exerciseCategories)
                    ..where((t) => t.id.equals(existing.id)))
                  .write(ExerciseCategoriesCompanion(
                      groupName: Value(groupName)));
            }
          } else {
            final id = await insertCategory(exerciseName, groupName: groupName);
            cache[exerciseName] = id;
          }
        }

        final ts = DateTime.parse(dateStr).millisecondsSinceEpoch + i;

        await into(workoutSets).insert(WorkoutSetsCompanion.insert(
          categoryId: cache[exerciseName]!,
          dateStr:    dateStr,
          timestamp:  ts,
          weightKg:   Value(weightKg),
          reps:       Value(reps),
          timeSecs:   Value(timeSecs),
        ));
        inserted++;
      }
    });
    return inserted;
  }

  // ── Workouts ──────────────────────────────────────────────────────────────

  Stream<List<Workout>> watchAllWorkouts() =>
      (select(workouts)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<int> insertWorkout(String name) =>
      into(workouts).insert(WorkoutsCompanion.insert(name: name));

  Future<int> renameWorkout(int id, String name) =>
      (update(workouts)..where((t) => t.id.equals(id)))
          .write(WorkoutsCompanion(name: Value(name)));

  Future<void> deleteWorkout(int id) async {
    await (delete(planWorkouts)..where((t) => t.workoutId.equals(id))).go();
    await (delete(workoutExercises)..where((t) => t.workoutId.equals(id))).go();
    await (delete(workouts)..where((t) => t.id.equals(id))).go();
  }

  // Returns (category, targetSets, targetReps) per exercise in the workout.
  Stream<List<(ExerciseCategory, int?, int?)>> watchExercisesForWorkout(int workoutId) {
    final q = select(workoutExercises).join([
      innerJoin(exerciseCategories,
          exerciseCategories.id.equalsExp(workoutExercises.categoryId)),
    ])
      ..where(workoutExercises.workoutId.equals(workoutId))
      ..orderBy([OrderingTerm.asc(exerciseCategories.name)]);
    return q.watch().map((rows) => rows
        .map((r) {
          final we = r.readTable(workoutExercises);
          return (
            r.readTable(exerciseCategories),
            we.targetSets,
            we.targetReps,
          );
        })
        .toList());
  }

  Future<int> updateWorkoutTarget(
          int workoutId, int categoryId, int? targetSets, int? targetReps) =>
      (update(workoutExercises)
            ..where((t) =>
                t.workoutId.equals(workoutId) & t.categoryId.equals(categoryId)))
          .write(WorkoutExercisesCompanion(
            targetSets: Value(targetSets),
            targetReps: Value(targetReps),
          ));

  Stream<List<Workout>> watchWorkoutsForExercise(int categoryId) {
    final q = select(workoutExercises).join([
      innerJoin(workouts, workouts.id.equalsExp(workoutExercises.workoutId)),
    ])
      ..where(workoutExercises.categoryId.equals(categoryId));
    return q.watch().map((rows) =>
        rows.map((r) => r.readTable(workouts)).toList());
  }

  Future<void> addExerciseToWorkout(int workoutId, int categoryId) =>
      into(workoutExercises).insertOnConflictUpdate(
        WorkoutExercisesCompanion.insert(
            workoutId: workoutId, categoryId: categoryId),
      );

  Future<int> removeExerciseFromWorkout(int workoutId, int categoryId) =>
      (delete(workoutExercises)
            ..where((t) =>
                t.workoutId.equals(workoutId) &
                t.categoryId.equals(categoryId)))
          .go();

  // ── Plans ─────────────────────────────────────────────────────────────────

  Stream<List<Plan>> watchAllPlans() =>
      (select(plans)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<int> insertPlan(String name) =>
      into(plans).insert(PlansCompanion.insert(name: name));

  Future<int> renamePlan(int id, String name) =>
      (update(plans)..where((t) => t.id.equals(id)))
          .write(PlansCompanion(name: Value(name)));

  Future<void> deletePlan(int id) async {
    await (delete(planWorkouts)..where((t) => t.planId.equals(id))).go();
    await (delete(plans)..where((t) => t.id.equals(id))).go();
  }

  // ── Plan ↔ Workout assignments ────────────────────────────────────────────

  Stream<List<PlanWorkout>> watchPlanWorkouts(int planId) =>
      (select(planWorkouts)..where((t) => t.planId.equals(planId))).watch();

  Future<int> assignWorkoutToPlan(int planId, int workoutId,
          {int? weekday, String? dateStr}) =>
      into(planWorkouts).insert(PlanWorkoutsCompanion.insert(
        planId:    planId,
        workoutId: workoutId,
        weekday:   Value(weekday),
        dateStr:   Value(dateStr),
      ));

  Future<int> removeWorkoutFromPlan(int assignmentId) =>
      (delete(planWorkouts)..where((t) => t.id.equals(assignmentId))).go();

  // ── Home screen: planned exercises for a date ─────────────────────────────

  Stream<Set<int>> watchPlannedCategoryIdsForDate(String dateStr) {
    final weekday = dateFromStr(dateStr).weekday;
    return customSelect(
      'SELECT DISTINCT we.category_id FROM workout_exercises we '
      'INNER JOIN plan_workouts pw ON we.workout_id = pw.workout_id '
      'WHERE pw.date_str = ? OR pw.weekday = ?',
      variables: [Variable.withString(dateStr), Variable.withInt(weekday)],
      readsFrom: {workoutExercises, planWorkouts},
    ).watch().map((rows) =>
        rows.map((r) => r.read<int>('category_id')).toSet());
  }

  /// Returns workouts scheduled for [dateStr] (by weekday or specific date),
  /// each paired with the exercises it contains — ordered alphabetically.
  Stream<List<(Workout, List<ExerciseCategory>)>> watchPlannedWorkoutsForDate(
      String dateStr) {
    final weekday = dateFromStr(dateStr).weekday;
    return customSelect(
      'SELECT DISTINCT w.id AS w_id, w.name AS w_name, '
      'ec.id AS c_id, ec.name AS c_name, ec.group_name '
      'FROM plan_workouts pw '
      'JOIN workouts w ON w.id = pw.workout_id '
      'JOIN workout_exercises we ON we.workout_id = pw.workout_id '
      'JOIN exercise_categories ec ON ec.id = we.category_id '
      'WHERE pw.date_str = ? OR pw.weekday = ? '
      'ORDER BY w.name, ec.name',
      variables: [Variable.withString(dateStr), Variable.withInt(weekday)],
      readsFrom: {planWorkouts, workouts, workoutExercises, exerciseCategories},
    ).watch().map((rows) {
      final order        = <int>[];
      final names        = <int, String>{};
      final exMap        = <int, List<ExerciseCategory>>{};
      for (final row in rows) {
        final wId    = row.read<int>('w_id');
        final wName  = row.read<String>('w_name');
        final cId    = row.read<int>('c_id');
        final cName  = row.read<String>('c_name');
        final cGroup = row.readNullable<String>('group_name');
        if (!names.containsKey(wId)) {
          order.add(wId);
          names[wId] = wName;
          exMap[wId] = [];
        }
        exMap[wId]!.add(ExerciseCategory(id: cId, name: cName, groupName: cGroup, exerciseType: 0));
      }
      return order
          .map((wId) => (Workout(id: wId, name: names[wId]!), exMap[wId]!))
          .toList();
    });
  }

  static String? _nullIfEmpty(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  static int? _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length != 3) return null;
    final h   = int.tryParse(parts[0]) ?? 0;
    final m   = int.tryParse(parts[1]) ?? 0;
    final sec = int.tryParse(parts[2]) ?? 0;
    final total = h * 3600 + m * 60 + sec;
    return total > 0 ? total : null;
  }
}
