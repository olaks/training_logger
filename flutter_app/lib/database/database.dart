import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';
export 'tables.dart' show PlanEventKind;
import '../utils/format_utils.dart';
import '../utils/periodization.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Workouts, WorkoutExercises, Plans, PlanWorkouts, PlanPhases, PhaseSessions, PhaseExerciseTargets, PlanEvents, ExerciseCategories, ExerciseImages, WorkoutSets, DayNotes, BodyWeights, Inspirations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(
    name: 'training_logger',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ));

  /// Test-only: run against a caller-supplied executor (e.g. in-memory).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Raw SQL because the column is gone from the current schema: v17
        // moves exercise photos into their own table, and a database this old
        // still has to pass through the version that had them here.
        await customStatement(
            'ALTER TABLE exercise_categories ADD COLUMN image_data BLOB');
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
      if (from < 11) {
        await m.addColumn(workouts, workouts.notes);
        await m.addColumn(workoutExercises, workoutExercises.sortOrder);
      }
      if (from < 12) {
        // Recreate workout_exercises without unique(workout_id, category_id)
        // so the same exercise can appear multiple times in a workout.
        await customStatement('''
          CREATE TABLE workout_exercises_new (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER NOT NULL REFERENCES workouts (id),
            category_id INTEGER NOT NULL REFERENCES exercise_categories (id),
            target_sets INTEGER,
            target_reps INTEGER,
            sort_order INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await customStatement('''
          INSERT INTO workout_exercises_new
            (id, workout_id, category_id, target_sets, target_reps, sort_order)
          SELECT id, workout_id, category_id, target_sets, target_reps, sort_order
          FROM workout_exercises
        ''');
        await customStatement('DROP TABLE workout_exercises');
        await customStatement(
            'ALTER TABLE workout_exercises_new RENAME TO workout_exercises');
      }
      if (from < 13) {
        await m.createTable(inspirations);
      }
      if (from < 14) {
        await m.addColumn(exerciseCategories, exerciseCategories.description);
      }
      if (from < 15) {
        await m.addColumn(workoutSets, workoutSets.wallAngle);
        await m.addColumn(workoutSets, workoutSets.climbName);
      }
      if (from < 16) {
        // Deleting an exercise used to drop only its category row, leaving
        // rows behind that point at a category that no longer exists. Those
        // sets are unreachable (nothing can display or export them) but still
        // marked their days as trained on the calendar. Clear them out before
        // foreign keys start being enforced in beforeOpen.
        await _purgeOrphans();
      }
      if (from < 17) {
        // Exercise photos move to their own table: see [ExerciseImages].
        await m.createTable(exerciseImages);
        if (await _hasColumn('exercise_categories', 'image_data')) {
          await customStatement(
              'INSERT INTO exercise_images (category_id, data) '
              'SELECT id, image_data FROM exercise_categories '
              'WHERE image_data IS NOT NULL');
          // Recreates the table from the current definition, copying the
          // columns that survive — which is how a column is dropped portably.
          await m.alterTable(TableMigration(exerciseCategories));
        }

        // The schema shipped without a single index, so every lookup by day,
        // by exercise, or through a foreign key scanned the whole table.
        for (final index in [
          idxSetsDate,
          idxSetsCategory,
          idxWeWorkout,
          idxWeCategory,
          idxPwPlan,
          idxPwWorkout,
          idxInspirationsCategory,
        ]) {
          // Dropped first so the index always ends up matching the definition
          // above, whatever an interrupted earlier run may have left behind.
          await customStatement('DROP INDEX IF EXISTS ${index.entityName}');
          await m.createIndex(index);
        }
      }
      if (from < 18) {
        // Periodized plans: see the tables' comments in tables.dart.
        await m.addColumn(plans, plans.active);
        await m.addColumn(workoutExercises, workoutExercises.targetRpe);
        await m.createTable(planPhases);
        await m.createTable(phaseSessions);
        await m.createTable(phaseExerciseTargets);
        await m.createTable(planEvents);
        for (final index in [
          idxPhasePlan,
          idxPsPhase,
          idxPsWorkout,
          idxPetPhase,
          idxPetCategory,
          idxPePlan,
          idxPePhase,
          idxPeWorkout,
        ]) {
          await m.createIndex(index);
        }
      }
    },
    beforeOpen: (details) async {
      // sqlite3 ignores foreign keys unless asked. Without this, a delete that
      // forgets to clean up its children fails silently instead of throwing.
      // Must run outside a transaction — the pragma is a no-op inside one,
      // which is why it lives here rather than in onUpgrade.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Whether a column is present, for migration steps that have to cope with
  /// a database that already went through part of the change.
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect(
      "SELECT 1 FROM pragma_table_info(?) WHERE name = ?",
      variables: [Variable.withString(table), Variable.withString(column)],
    ).get();
    return rows.isNotEmpty;
  }

  /// Deletes rows whose parent is gone, so foreign key enforcement has a
  /// consistent database to start from.
  Future<void> _purgeOrphans() async {
    const statements = [
      'DELETE FROM workout_sets WHERE category_id NOT IN '
          '(SELECT id FROM exercise_categories)',
      'DELETE FROM workout_exercises WHERE category_id NOT IN '
          '(SELECT id FROM exercise_categories)',
      'DELETE FROM workout_exercises WHERE workout_id NOT IN '
          '(SELECT id FROM workouts)',
      'DELETE FROM plan_workouts WHERE workout_id NOT IN '
          '(SELECT id FROM workouts)',
      'DELETE FROM plan_workouts WHERE plan_id NOT IN (SELECT id FROM plans)',
      // Inspirations link to an exercise optionally, so a dangling link is
      // cleared rather than taking the saved video down with it.
      'UPDATE inspirations SET category_id = NULL WHERE category_id IS NOT NULL '
          'AND category_id NOT IN (SELECT id FROM exercise_categories)',
    ];
    for (final sql in statements) {
      await customStatement(sql);
    }
  }

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

  Stream<ExerciseCategory?> watchCategoryById(int id) =>
      (select(exerciseCategories)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<int> insertCategory(String name, {String? groupName, String? description}) =>
      into(exerciseCategories).insert(ExerciseCategoriesCompanion.insert(
        name: name,
        groupName: Value(groupName),
        description: Value(description),
      ));

  /// Returns existing category id if name matches (case-insensitive),
  /// otherwise inserts a new one.
  Future<int> insertOrGetCategory(String name, {String? groupName, String? description}) async {
    final match = (await _categoriesNamed(name)).firstOrNull;
    if (match != null) return match.id;
    return insertCategory(name, groupName: groupName, description: description);
  }

  /// Exercises matching [name], ignoring case. Names are not unique in the
  /// schema, so this returns a list rather than assuming one row: a lookup
  /// that assumed uniqueness used to throw on a library holding two exercises
  /// of the same name, which a rename can produce.
  Future<List<ExerciseCategory>> _categoriesNamed(String name) async {
    // `like` is the case-insensitive prefilter SQLite gives us; `%` and `_`
    // in a name make it over-match, so the exact comparison happens in Dart.
    final candidates =
        await (select(exerciseCategories)..where((t) => t.name.like(name))).get();
    final lower = name.toLowerCase();
    return candidates.where((c) => c.name.toLowerCase() == lower).toList();
  }

  /// Renames an exercise, refusing a name another exercise already answers to.
  ///
  /// The edit screen checks this too, but it checks against a cached list;
  /// the constraint belongs where the write happens, because a duplicate name
  /// is what makes a later backup import ambiguous.
  Future<int> renameCategory(int id, String name) async {
    final clash = (await _categoriesNamed(name)).where((c) => c.id != id);
    if (clash.isNotEmpty) throw DuplicateNameException(name);
    return (update(exerciseCategories)..where((t) => t.id.equals(id)))
        .write(ExerciseCategoriesCompanion(name: Value(name)));
  }

  Future<int> updateCategoryGroup(int id, String? groupName) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(groupName: Value(groupName)));

  Future<int> updateCategoryDescription(int id, String? description) =>
      (update(exerciseCategories)..where((t) => t.id.equals(id)))
          .write(ExerciseCategoriesCompanion(description: Value(description)));

  /// Number of logged sets and containing workouts that [deleteCategory]
  /// would take with the exercise.
  Future<({int sets, int workouts})> categoryDeletionImpact(int id) async {
    final setCount = await (selectOnly(workoutSets)
          ..addColumns([workoutSets.id.count()])
          ..where(workoutSets.categoryId.equals(id)))
        .map((r) => r.read(workoutSets.id.count()) ?? 0)
        .getSingle();
    final workoutCount = await (selectOnly(workoutExercises, distinct: true)
          ..addColumns([workoutExercises.workoutId])
          ..where(workoutExercises.categoryId.equals(id)))
        .get()
        .then((rows) => rows.length);
    return (sets: setCount, workouts: workoutCount);
  }

  /// Deletes an exercise along with everything that references it, returning
  /// what was removed so it can be put back. Logged sets go too: with the
  /// category gone they can't be displayed or exported, so leaving them behind
  /// only produced unreachable rows that still marked their days as trained.
  Future<DeletedCategory?> deleteCategory(int id) => transaction(() async {
        final category = await (select(exerciseCategories)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (category == null) return null;

        final sets = await (select(workoutSets)
              ..where((t) => t.categoryId.equals(id)))
            .get();
        final members = await (select(workoutExercises)
              ..where((t) => t.categoryId.equals(id)))
            .get();
        final linked = await (select(inspirations)
              ..where((t) => t.categoryId.equals(id)))
            .get();
        final image = await getCategoryImage(id);
        final phaseTargets = await (select(phaseExerciseTargets)
              ..where((t) => t.categoryId.equals(id)))
            .get();

        await (delete(phaseExerciseTargets)
              ..where((t) => t.categoryId.equals(id)))
            .go();
        await (delete(exerciseImages)..where((t) => t.categoryId.equals(id)))
            .go();
        await (delete(workoutSets)..where((t) => t.categoryId.equals(id))).go();
        await (delete(workoutExercises)..where((t) => t.categoryId.equals(id)))
            .go();
        // Saved videos outlive the exercise they were filed under.
        await (update(inspirations)..where((t) => t.categoryId.equals(id)))
            .write(const InspirationsCompanion(categoryId: Value(null)));
        await (delete(exerciseCategories)..where((t) => t.id.equals(id))).go();

        return DeletedCategory(
          category: category,
          sets: sets,
          memberships: members,
          unlinkedInspirationIds: linked.map((i) => i.id).toList(),
          image: image,
          phaseTargets: phaseTargets,
        );
      });

  /// Reverses [deleteCategory]. The exercise goes back first so everything
  /// pointing at it has something to point at.
  Future<void> restoreCategory(DeletedCategory deleted) => transaction(() async {
        await into(exerciseCategories)
            .insert(deleted.category.toCompanion(false));
        if (deleted.image != null) {
          await setCategoryImage(deleted.category.id, deleted.image);
        }
        for (final s in deleted.sets) {
          await into(workoutSets).insert(s.toCompanion(false));
        }
        for (final m in deleted.memberships) {
          await into(workoutExercises).insert(m.toCompanion(false));
        }
        for (final t in deleted.phaseTargets) {
          await into(phaseExerciseTargets).insert(t.toCompanion(false));
        }
        for (final id in deleted.unlinkedInspirationIds) {
          await (update(inspirations)..where((t) => t.id.equals(id)))
              .write(InspirationsCompanion(
                  categoryId: Value(deleted.category.id)));
        }
      });

  // ── Exercise images ───────────────────────────────────────────────────────

  /// The photo for one exercise, or null if it has none. Watched only by the
  /// two widgets that draw it — see [ExerciseImages] for why it is separate.
  Stream<Uint8List?> watchCategoryImage(int id) =>
      (select(exerciseImages)..where((t) => t.categoryId.equals(id)))
          .watchSingleOrNull()
          .map((row) => row?.data);

  Future<Uint8List?> getCategoryImage(int id) async {
    final row = await (select(exerciseImages)
          ..where((t) => t.categoryId.equals(id)))
        .getSingleOrNull();
    return row?.data;
  }

  /// Every photo at once, keyed by exercise. Only the backup export needs
  /// this; screens fetch one at a time.
  Future<Map<int, Uint8List>> getAllCategoryImages() async {
    final rows = await select(exerciseImages).get();
    return {for (final r in rows) r.categoryId: r.data};
  }

  /// Writes or clears an exercise photo. Null removes the row rather than
  /// storing an empty blob.
  Future<void> setCategoryImage(int id, Uint8List? data) async {
    if (data == null) {
      await (delete(exerciseImages)..where((t) => t.categoryId.equals(id))).go();
      return;
    }
    await into(exerciseImages).insertOnConflictUpdate(
        ExerciseImagesCompanion.insert(categoryId: Value(id), data: data));
  }

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

  /// Every logged set, oldest first — the whole history, which is what a
  /// rolling training-load window has to walk.
  Stream<List<WorkoutSet>> watchAllSets() =>
      (select(workoutSets)
            ..orderBy([
              (t) => OrderingTerm.asc(t.dateStr),
              (t) => OrderingTerm.asc(t.timestamp),
            ]))
          .watch();

  Stream<List<String>> watchWorkoutDates() => customSelect(
        'SELECT DISTINCT date_str FROM workout_sets ORDER BY date_str ASC',
        readsFrom: {workoutSets},
      ).map((row) => row.read<String>('date_str')).watch();

  Future<int> insertSet(WorkoutSetsCompanion set) =>
      into(workoutSets).insert(set);

  /// Overwrites a logged set. Every field is written, so leaving one out
  /// clears it — an edit replaces the set rather than merging into it.
  Future<int> updateSet(
    int id, {
    double? weightKg,
    int? reps,
    int? timeSecs,
    int? rpe,
    String? grade,
    int? wallAngle,
    String? climbName,
  }) =>
      (update(workoutSets)..where((t) => t.id.equals(id))).write(
        WorkoutSetsCompanion(
          weightKg:  Value(weightKg),
          reps:      Value(reps),
          timeSecs:  Value(timeSecs),
          rpe:       Value(rpe),
          grade:     Value(grade),
          wallAngle: Value(wallAngle),
          climbName: Value(climbName),
        ),
      );

  /// Deletes a set and hands back what was removed, so the caller can offer
  /// an undo. Returns null if the set was already gone.
  Future<WorkoutSet?> deleteSet(int id) async {
    final row = await (select(workoutSets)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    await (delete(workoutSets)..where((t) => t.id.equals(id))).go();
    return row;
  }

  /// Puts a deleted set back exactly as it was, id included.
  Future<void> restoreSet(WorkoutSet set) =>
      into(workoutSets).insert(set.toCompanion(false));

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

  // ── Inspirations ──────────────────────────────────────────────────────────

  Stream<List<Inspiration>> watchInspirations({int? categoryId}) {
    final q = select(inspirations)
      ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]);
    if (categoryId != null) {
      q.where((t) => t.categoryId.equals(categoryId));
    }
    return q.watch();
  }

  /// [addedAt] is only passed when restoring from a backup, so a re-imported
  /// link keeps its original place in the list.
  Future<int> insertInspiration({
    required String title,
    required String url,
    String? notes,
    int? categoryId,
    int? addedAt,
  }) =>
      into(inspirations).insert(InspirationsCompanion.insert(
        title: title,
        url: url,
        notes: Value(notes),
        categoryId: Value(categoryId),
        addedAt: addedAt ?? DateTime.now().millisecondsSinceEpoch,
      ));

  Future<int> updateInspiration(
    int id, {
    required String title,
    required String url,
    String? notes,
    int? categoryId,
  }) =>
      (update(inspirations)..where((t) => t.id.equals(id))).write(
        InspirationsCompanion(
          title:      Value(title),
          url:        Value(url),
          notes:      Value(notes),
          categoryId: Value(categoryId),
        ),
      );

  Future<int> deleteInspiration(int id) =>
      (delete(inspirations)..where((t) => t.id.equals(id))).go();

  // ── Export plan ───────────────────────────────────────────────────────────

  Future<String> exportPlanToJson(int planId) async {
    final plan = await (select(plans)..where((t) => t.id.equals(planId)))
        .getSingleOrNull();
    if (plan == null) throw StateError('Plan $planId not found');

    final assignments =
        await (select(planWorkouts)..where((t) => t.planId.equals(planId))).get();
    final phaseIds = await (select(planPhases)
          ..where((t) => t.planId.equals(planId)))
        .map((p) => p.id)
        .get();
    final rotationWorkoutIds = await (select(phaseSessions)
          ..where((t) => t.phaseId.isIn(phaseIds)))
        .map((s) => s.workoutId)
        .get();
    final workoutIds =
        {...assignments.map((a) => a.workoutId), ...rotationWorkoutIds}.toList();

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
        if (workout.notes.isNotEmpty) 'notes': workout.notes,
        'exercises': rows.map((row) {
          final we = row.readTable(workoutExercises);
          final ec = row.readTable(exerciseCategories);
          return <String, dynamic>{
            'name': ec.name,
            if (ec.groupName  != null) 'group':      ec.groupName,
            if (we.targetSets != null) 'targetSets': we.targetSets,
            if (we.targetReps != null) 'targetReps': we.targetReps,
            if (we.targetRpe  != null) 'targetRpe':  we.targetRpe,
            'sortOrder': we.sortOrder,
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
        // A shared plan is a template: its phases travel, its log doesn't.
        'phases': await _phasesToJson(planId,
            workoutNames: {for (final w in planWorkoutsList) w.id: w.name},
            categoryNames: await _categoryNames(),
            withLog: false),
      },
    });
  }

  // ── Import plan ───────────────────────────────────────────────────────────

  /// Imports a single-plan JSON produced by [exportPlanToJson].
  ///
  /// - Plan: matched by name. If present, the plan id is preserved and its
  ///   weekday/date assignments are REPLACED. Otherwise a new plan is created.
  /// - Workouts: merged by name. Existing workouts are reused as-is; only
  ///   workouts with names not yet in the library are created (with their
  ///   exercise list).
  /// - Exercise categories: merged by name; missing ones are created.
  ///
  /// Returns the plan id.
  Future<int> importPlanFromJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final planJson = data['plan'] as Map<String, dynamic>?;
    if (planJson == null) {
      throw const FormatException('Not a plan export: missing "plan" key.');
    }
    final planName = planJson['name'] as String?;
    if (planName == null || planName.isEmpty) {
      throw const FormatException('Plan export missing "name".');
    }

    final workoutsJson =
        (planJson['workouts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final assignmentsJson =
        (planJson['assignments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    late int planId;
    await transaction(() async {
      // ── Plan ──────────────────────────────────────────────────────────
      final existingPlan = (await (select(plans)
            ..where((t) => t.name.equals(planName)))
          .get())
          .firstOrNull;
      if (existingPlan == null) {
        planId = await into(plans).insert(PlansCompanion.insert(name: planName));
      } else {
        planId = existingPlan.id;
        await (delete(planWorkouts)..where((t) => t.planId.equals(planId))).go();
      }

      // ── Workouts (merge by name; create missing with their exercises) ─
      final workoutIdByName = <String, int>{};
      final catIdByName     = <String, int>{};

      for (final w in workoutsJson) {
        final name  = w['name'] as String;
        final notes = (w['notes'] as String?) ?? '';

        final existingW = (await (select(workouts)
              ..where((t) => t.name.equals(name)))
            .get())
            .firstOrNull;

        int wId;
        if (existingW != null) {
          wId = existingW.id;
        } else {
          wId = await into(workouts).insert(
              WorkoutsCompanion.insert(name: name, notes: Value(notes)));

          final exList =
              (w['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          for (final we in exList) {
            final exName = we['name'] as String;
            final group  = we['group'] as String?;

            int catId;
            if (catIdByName.containsKey(exName)) {
              catId = catIdByName[exName]!;
            } else {
              catId = await insertOrGetCategory(exName, groupName: group);
              catIdByName[exName] = catId;
            }

            await into(workoutExercises).insert(
              WorkoutExercisesCompanion.insert(
                workoutId:  wId,
                categoryId: catId,
                targetSets: Value((we['targetSets'] as num?)?.toInt()),
                targetReps: Value((we['targetReps'] as num?)?.toInt()),
                targetRpe:  Value((we['targetRpe']  as num?)?.toInt()),
                sortOrder:  Value((we['sortOrder']  as num?)?.toInt() ?? 0),
              ),
            );
          }
        }
        workoutIdByName[name] = wId;
      }

      // ── Assignments ───────────────────────────────────────────────────
      for (final a in assignmentsJson) {
        final woName = a['workout'] as String?;
        if (woName == null || woName.isEmpty) continue;

        int? woId = workoutIdByName[woName];
        if (woId == null) {
          // Fallback for hand-edited JSON that references a workout
          // already in the library but not listed under "workouts".
          final existing = (await (select(workouts)
                ..where((t) => t.name.equals(woName)))
              .get())
              .firstOrNull;
          if (existing == null) continue;
          woId = existing.id;
          workoutIdByName[woName] = woId;
        }

        await into(planWorkouts).insert(PlanWorkoutsCompanion.insert(
          planId:    planId,
          workoutId: woId,
          weekday:   Value((a['weekday'] as num?)?.toInt()),
          dateStr:   Value(a['date'] as String?),
        ));
      }

      // ── Phases (replace, like the assignments) ────────────────────────
      final phasesJson =
          (planJson['phases'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (phasesJson.isNotEmpty) {
        final existing = await (select(planPhases)
              ..where((t) => t.planId.equals(planId)))
            .get();
        for (final phase in existing) {
          await deletePhase(phase.id);
        }
        final workoutByName = {
          for (final w in await select(workouts).get()) w.name: w.id,
          ...workoutIdByName,
        };
        await _phasesFromJson(planId, phasesJson,
            workoutId: (name) => workoutByName[name],
            categoryId: (name) async =>
                catIdByName[name] ?? await insertOrGetCategory(name));
      }
    });
    return planId;
  }

  Future<Map<int, String>> _categoryNames() async => {
        for (final c in await select(exerciseCategories).get()) c.id: c.name,
      };

  /// A plan's phases for an export, everything referenced by name. [withLog]
  /// adds the record of sessions done: a backup wants it, a shared plan
  /// doesn't.
  Future<List<Map<String, dynamic>>> _phasesToJson(
    int planId, {
    required Map<int, String> workoutNames,
    required Map<int, String> categoryNames,
    required bool withLog,
  }) async {
    final phases = await (select(planPhases)
          ..where((t) => t.planId.equals(planId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return [
      for (final phase in phases)
        <String, dynamic>{
          'name': phase.name,
          'lengthPasses': phase.lengthPasses,
          if (phase.deloadEvery != null) 'deloadEvery': phase.deloadEvery,
          'sessions': [
            for (final s in await (select(phaseSessions)
                  ..where((t) => t.phaseId.equals(phase.id))
                  ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
                .get())
              workoutNames[s.workoutId] ?? '',
          ],
          'targets': [
            for (final t in await (select(phaseExerciseTargets)
                  ..where((t) => t.phaseId.equals(phase.id)))
                .get())
              <String, dynamic>{
                'exercise': categoryNames[t.categoryId] ?? '',
                if (t.targetRpe  != null) 'rpe':  t.targetRpe,
                if (t.targetSets != null) 'sets': t.targetSets,
                if (t.targetReps != null) 'reps': t.targetReps,
              },
          ],
          if (withLog)
            'log': [
              for (final e in await (select(planEvents)
                    ..where((t) => t.phaseId.equals(phase.id))
                    ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
                  .get())
                <String, dynamic>{
                  'kind': e.kind.name,
                  if (e.workoutId != null)
                    'workout': workoutNames[e.workoutId] ?? '',
                  if (e.pass != null) 'pass': e.pass,
                  if (e.closesPass) 'closesPass': true,
                  'date': e.dateStr,
                  'timestamp': e.timestamp,
                },
            ],
        },
    ];
  }

  /// Adds [phasesJson] (as written by [_phasesToJson]) to [planId], after any
  /// phases it has. Sessions, targets and log entries naming a workout or
  /// exercise that can't be found are dropped rather than failing the import.
  ///
  /// A plan that would make a second running periodized plan is paused.
  Future<void> _phasesFromJson(
    int planId,
    List<Map<String, dynamic>> phasesJson, {
    required int? Function(String name) workoutId,
    required Future<int?> Function(String name) categoryId,
  }) async {
    final running = await activePlan();
    for (final p in phasesJson) {
      final phaseId = await insertPhase(planId, p['name'] as String,
          lengthPasses: (p['lengthPasses'] as num).toInt(),
          deloadEvery: (p['deloadEvery'] as num?)?.toInt());

      for (final name in (p['sessions'] as List? ?? []).cast<String>()) {
        final w = workoutId(name);
        if (w != null) await addSessionToPhase(phaseId, w);
      }
      for (final t in (p['targets'] as List? ?? []).cast<Map<String, dynamic>>()) {
        final c = await categoryId(t['exercise'] as String);
        if (c == null) continue;
        await setPhaseExerciseTarget(phaseId, c,
            rpe: (t['rpe'] as num?)?.toInt(),
            sets: (t['sets'] as num?)?.toInt(),
            reps: (t['reps'] as num?)?.toInt());
      }
      for (final e in (p['log'] as List? ?? []).cast<Map<String, dynamic>>()) {
        final kind = PlanEventKind.values
            .where((k) => k.name == e['kind'])
            .firstOrNull;
        if (kind == null) continue;
        // An entry whose workout can't be found keeps its place in the log
        // without one, the way deleting a workout leaves it.
        final workoutName = e['workout'] as String?;
        final w = workoutName == null ? null : workoutId(workoutName);
        await into(planEvents).insert(PlanEventsCompanion.insert(
          planId: planId,
          phaseId: phaseId,
          workoutId: Value(w),
          pass: Value((e['pass'] as num?)?.toInt()),
          closesPass: Value(e['closesPass'] as bool? ?? false),
          dateStr: e['date'] as String,
          timestamp: (e['timestamp'] as num).toInt(),
          kind: kind,
        ));
      }
    }
    if (running != null && running.plan.id != planId) {
      await (update(plans)..where((t) => t.id.equals(planId)))
          .write(const PlansCompanion(active: Value(false)));
    }
  }

  // ── Export / Import backup ────────────────────────────────────────────────

  Future<String> exportToJson() async {
    final cats    = await select(exerciseCategories).get();
    final allSets = await select(workoutSets).get();
    final images  = await getAllCategoryImages();

    final setsByCategory = <int, List<WorkoutSet>>{};
    for (final s in allSets) {
      setsByCategory.putIfAbsent(s.categoryId, () => []).add(s);
    }
    final catNameById = {for (final c in cats) c.id: c.name};

    // ── Exercises + sets ────────────────────────────────────────────────
    final exercisesJson = cats.map((cat) {
      final sets = (setsByCategory[cat.id] ?? []).map((s) => <String, dynamic>{
        'date':      s.dateStr,
        'timestamp': s.timestamp,
        if (s.weightKg  != null) 'weightKg':  s.weightKg,
        if (s.reps      != null) 'reps':      s.reps,
        if (s.timeSecs  != null) 'timeSecs':  s.timeSecs,
        if (s.rpe       != null) 'rpe':       s.rpe,
        if (s.grade     != null) 'grade':     s.grade,
        if (s.wallAngle != null) 'wallAngle': s.wallAngle,
        if (s.climbName != null) 'climbName': s.climbName,
      }).toList();

      return <String, dynamic>{
        'name': cat.name,
        if (cat.groupName   != null) 'group':        cat.groupName,
        if (cat.description != null) 'description':  cat.description,
        if (images[cat.id]  != null) 'image':        base64.encode(images[cat.id]!),
        if (cat.exerciseType != 0)   'exerciseType': cat.exerciseType,
        'sets': sets,
      };
    }).toList();

    // ── Workouts ────────────────────────────────────────────────────────
    final allWorkouts = await select(workouts).get();
    final allWe       = await select(workoutExercises).get();
    final weByWorkout = <int, List<WorkoutExercise>>{};
    for (final we in allWe) {
      weByWorkout.putIfAbsent(we.workoutId, () => []).add(we);
    }
    final workoutsJson = allWorkouts.map((w) {
      final exList = (weByWorkout[w.id] ?? [])
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return <String, dynamic>{
        'name': w.name,
        if (w.notes.isNotEmpty) 'notes': w.notes,
        'exercises': exList.map((we) => <String, dynamic>{
          'name': catNameById[we.categoryId] ?? '',
          if (we.targetSets != null) 'targetSets': we.targetSets,
          if (we.targetReps != null) 'targetReps': we.targetReps,
          if (we.targetRpe  != null) 'targetRpe':  we.targetRpe,
          'sortOrder': we.sortOrder,
        }).toList(),
      };
    }).toList();

    // ── Plans ───────────────────────────────────────────────────────────
    final allPlans = await select(plans).get();
    final allPw    = await select(planWorkouts).get();
    final pwByPlan = <int, List<PlanWorkout>>{};
    for (final pw in allPw) {
      pwByPlan.putIfAbsent(pw.planId, () => []).add(pw);
    }
    final workoutNameById = {for (final w in allWorkouts) w.id: w.name};
    final plansJson = [
      for (final p in allPlans)
        <String, dynamic>{
          'name': p.name,
          if (!p.active) 'active': false,
          'assignments': (pwByPlan[p.id] ?? []).map((pw) => <String, dynamic>{
            'workout': workoutNameById[pw.workoutId] ?? '',
            if (pw.weekday != null) 'weekday': pw.weekday,
            if (pw.dateStr != null) 'date':    pw.dateStr,
          }).toList(),
          'phases': await _phasesToJson(p.id,
              workoutNames: workoutNameById,
              categoryNames: catNameById,
              withLog: true),
        },
    ];

    // ── Day notes + body weights ────────────────────────────────────────
    final notes   = await select(dayNotes).get();
    final weights = await select(bodyWeights).get();

    // ── Inspirations ────────────────────────────────────────────────────
    final links = await select(inspirations).get();
    final inspirationsJson = links.map((i) => <String, dynamic>{
      'title': i.title,
      'url':   i.url,
      if (i.notes != null) 'notes': i.notes,
      if (i.categoryId != null && catNameById[i.categoryId] != null)
        'exercise': catNameById[i.categoryId],
      'addedAt': i.addedAt,
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'version':      3,
      'exportedAt':   DateTime.now().toIso8601String(),
      'exercises':    exercisesJson,
      'workouts':     workoutsJson,
      'plans':        plansJson,
      'dayNotes':     notes.map((n) => {'date': n.dateStr, 'note': n.note}).toList(),
      'bodyWeights':  weights.map((b) => {'date': b.dateStr, 'kg': b.kg}).toList(),
      'inspirations': inspirationsJson,
    });
  }

  /// Merges a backup into the current database, returning how many sets were
  /// added.
  ///
  /// Everything is matched by name, and nothing already present is touched —
  /// importing the same file twice adds nothing the second time. The lookups
  /// that decide "already present" are all built once up front: doing them per
  /// row meant a query per set, which on a full history was thousands of round
  /// trips inside a single transaction.
  Future<int> importFromJson(String jsonStr) async {
    final data      = jsonDecode(jsonStr) as Map<String, dynamic>;
    final exercises = (data['exercises'] as List).cast<Map<String, dynamic>>();
    int inserted    = 0;

    // Map of lower-cased exercise name → catId. Matching ignores case, so a
    // backup written as "Pull Up" merges into an existing "pull up" instead of
    // forking its history into a second exercise.
    final catIdByName = <String, int>{};

    await transaction(() async {
      // ── What is already here ──────────────────────────────────────────
      final existingCats = await select(exerciseCategories).get();
      final catByName = <String, ExerciseCategory>{};
      for (final c in existingCats) {
        catByName.putIfAbsent(c.name.toLowerCase(), () => c);
      }
      final withImages = (await (selectOnly(exerciseImages)
                ..addColumns([exerciseImages.categoryId]))
              .get())
          .map((r) => r.read(exerciseImages.categoryId)!)
          .toSet();
      // (categoryId, timestamp) identifies a logged set for de-duplication.
      final existingSets = (await (selectOnly(workoutSets)
                ..addColumns([workoutSets.categoryId, workoutSets.timestamp]))
              .get())
          .map((r) => (
                r.read(workoutSets.categoryId)!,
                r.read(workoutSets.timestamp)!
              ))
          .toSet();

      // ── Exercises + sets ──────────────────────────────────────────────
      final newSets = <WorkoutSetsCompanion>[];
      for (final ex in exercises) {
        final name        = ex['name']        as String;
        final key         = name.toLowerCase();
        final group       = ex['group']       as String?;
        final description = ex['description'] as String?;
        final imageB64    = ex['image']       as String?;
        final exType      = (ex['exerciseType'] as int?) ?? 0;

        int catId;
        final existing = catByName[key];

        if (existing == null) {
          catId = await insertCategory(name,
              groupName: group, description: description);
          if (imageB64 != null) {
            await setCategoryImage(catId, base64.decode(imageB64));
            withImages.add(catId);
          }
          if (exType != 0) {
            await setExerciseType(catId, exType);
          }
        } else {
          catId = existing.id;
          // Only fills gaps: an exercise already carrying a group, a
          // description or a photo keeps the one it has.
          final patch = ExerciseCategoriesCompanion(
            groupName: existing.groupName == null && group != null
                ? Value(group)
                : const Value.absent(),
            description: existing.description == null && description != null
                ? Value(description)
                : const Value.absent(),
          );
          if (patch.groupName.present || patch.description.present) {
            await (update(exerciseCategories)
                  ..where((t) => t.id.equals(catId)))
                .write(patch);
          }
          if (imageB64 != null && !withImages.contains(catId)) {
            await setCategoryImage(catId, base64.decode(imageB64));
            withImages.add(catId);
          }
        }
        catIdByName[key] = catId;

        for (final s in (ex['sets'] as List).cast<Map<String, dynamic>>()) {
          final ts = s['timestamp'] as int;
          if (!existingSets.add((catId, ts))) continue;

          newSets.add(WorkoutSetsCompanion.insert(
            categoryId: catId,
            dateStr:    s['date'] as String,
            timestamp:  ts,
            weightKg:   Value((s['weightKg']  as num?)?.toDouble()),
            reps:       Value((s['reps']      as num?)?.toInt()),
            timeSecs:   Value((s['timeSecs']  as num?)?.toInt()),
            rpe:        Value((s['rpe']       as num?)?.toInt()),
            grade:      Value(s['grade']      as String?),
            wallAngle:  Value((s['wallAngle'] as num?)?.toInt()),
            climbName:  Value(s['climbName']  as String?),
          ));
          inserted++;
        }
      }
      if (newSets.isNotEmpty) {
        await batch((b) => b.insertAll(workoutSets, newSets));
      }

      // ── Workouts ──────────────────────────────────────────────────────
      final workoutsData = (data['workouts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final workoutIdByName = <String, int>{};
      for (final w in await select(workouts).get()) {
        workoutIdByName.putIfAbsent(w.name.toLowerCase(), () => w.id);
      }
      // (workoutId, categoryId, sortOrder) is what makes a membership the one
      // already in the workout rather than a second copy of the exercise.
      final existingMembers = (await select(workoutExercises).get())
          .map((we) => (we.workoutId, we.categoryId, we.sortOrder))
          .toSet();

      for (final w in workoutsData) {
        final name  = w['name'] as String;
        final key   = name.toLowerCase();
        final notes = (w['notes'] as String?) ?? '';

        var wId = workoutIdByName[key];
        if (wId == null) {
          wId = await into(workouts).insert(
              WorkoutsCompanion.insert(name: name, notes: Value(notes)));
          workoutIdByName[key] = wId;
        }

        final exList = (w['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final we in exList) {
          final catId = catIdByName[(we['name'] as String).toLowerCase()];
          if (catId == null) continue;

          final sortOrder = (we['sortOrder'] as num?)?.toInt() ?? 0;
          if (!existingMembers.add((wId, catId, sortOrder))) continue;

          await into(workoutExercises).insert(
            WorkoutExercisesCompanion.insert(
              workoutId:  wId,
              categoryId: catId,
              targetSets: Value((we['targetSets'] as num?)?.toInt()),
              targetReps: Value((we['targetReps'] as num?)?.toInt()),
              targetRpe:  Value((we['targetRpe']  as num?)?.toInt()),
              sortOrder:  Value(sortOrder),
            ),
          );
        }
      }

      // ── Plans ─────────────────────────────────────────────────────────
      final plansData = (data['plans'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final planIdByName = <String, int>{};
      for (final p in await select(plans).get()) {
        planIdByName.putIfAbsent(p.name.toLowerCase(), () => p.id);
      }
      final existingAssignments = (await select(planWorkouts).get())
          .map((pw) => (pw.planId, pw.workoutId))
          .toSet();

      for (final p in plansData) {
        final name = p['name'] as String;
        final key  = name.toLowerCase();

        var planId = planIdByName[key];
        if (planId == null) {
          planId = await into(plans).insert(PlansCompanion.insert(
              name: name, active: Value(p['active'] as bool? ?? true)));
          planIdByName[key] = planId;
        }

        // Phases only go into a plan that has none: one already periodized
        // here keeps its own, as everything already present does.
        final phasesData =
            (p['phases'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (phasesData.isNotEmpty && !await _isPeriodized(planId)) {
          await _phasesFromJson(planId, phasesData,
              workoutId: (name) => workoutIdByName[name.toLowerCase()],
              categoryId: (name) async => catIdByName[name.toLowerCase()]);
        }

        final assignments = (p['assignments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (final a in assignments) {
          final woId = workoutIdByName[(a['workout'] as String).toLowerCase()];
          if (woId == null) continue;
          if (!existingAssignments.add((planId, woId))) continue;

          await into(planWorkouts).insert(PlanWorkoutsCompanion.insert(
            planId:    planId,
            workoutId: woId,
            weekday:   Value((a['weekday'] as num?)?.toInt()),
            dateStr:   Value(a['date'] as String?),
          ));
        }
      }

      // ── Day notes ─────────────────────────────────────────────────────
      final notesData = (data['dayNotes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final notedDays = (await select(dayNotes).get()).map((n) => n.dateStr).toSet();
      for (final n in notesData) {
        final dateStr = n['date'] as String;
        final note    = n['note'] as String;
        if (note.isEmpty || !notedDays.add(dateStr)) continue;
        await saveDayNote(dateStr, note);
      }

      // ── Body weights ──────────────────────────────────────────────────
      final weightsData = (data['bodyWeights'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final weighedDays =
          (await select(bodyWeights).get()).map((b) => b.dateStr).toSet();
      for (final b in weightsData) {
        final dateStr = b['date'] as String;
        if (!weighedDays.add(dateStr)) continue;
        await saveBodyWeight(dateStr, (b['kg'] as num).toDouble());
      }

      // ── Inspirations ──────────────────────────────────────────────────
      // Absent from exports before version 3; older files just skip this.
      final linksData =
          (data['inspirations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final existingLinks =
          (await select(inspirations).get()).map((i) => (i.url, i.title)).toSet();
      for (final i in linksData) {
        final url   = i['url'] as String;
        final title = i['title'] as String;
        if (!existingLinks.add((url, title))) continue;

        await insertInspiration(
          title:      title,
          url:        url,
          notes:      i['notes'] as String?,
          categoryId: catIdByName[(i['exercise'] as String? ?? '').toLowerCase()],
          addedAt:    (i['addedAt'] as num?)?.toInt(),
        );
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
          final existing = (await _categoriesNamed(exerciseName)).firstOrNull;
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

  /// Returns [base] if no workout uses it, otherwise "[base] 2", "[base] 3"…
  Future<String> uniqueWorkoutName(String base) async {
    final taken = (await select(workouts).get()).map((w) => w.name).toSet();
    if (!taken.contains(base)) return base;
    for (var n = 2;; n++) {
      final candidate = '$base $n';
      if (!taken.contains(candidate)) return candidate;
    }
  }

  /// Copies [workoutId] into a new workout with the same notes, exercises,
  /// targets and order. Falls back to `<name> (copy)` when [newName] is blank.
  Future<int> duplicateWorkout(int workoutId, {String? newName}) async {
    final source =
        await (select(workouts)..where((t) => t.id.equals(workoutId)))
            .getSingleOrNull();
    if (source == null) throw StateError('No workout with id $workoutId');

    final trimmed = newName?.trim() ?? '';
    final name = trimmed.isNotEmpty
        ? trimmed
        : await uniqueWorkoutName('${source.name} (copy)');

    final rows = await (select(workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return transaction(() async {
      final newId = await into(workouts).insert(
          WorkoutsCompanion.insert(name: name, notes: Value(source.notes)));
      for (var i = 0; i < rows.length; i++) {
        await into(workoutExercises).insert(WorkoutExercisesCompanion.insert(
          workoutId:  newId,
          categoryId: rows[i].categoryId,
          targetSets: Value(rows[i].targetSets),
          targetReps: Value(rows[i].targetReps),
          targetRpe:  Value(rows[i].targetRpe),
          sortOrder:  Value(i),
        ));
      }
      return newId;
    });
  }

  /// Builds a workout named [name] from the sets logged on [dateStr]: one
  /// entry per exercise in first-logged order, the number of logged sets as
  /// the sets target, and the rep count as the reps target when every set of
  /// that exercise used the same reps.
  Future<int> createWorkoutFromDay(String dateStr, String name) async {
    final sets = await (select(workoutSets)
          ..where((t) => t.dateStr.equals(dateStr))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    if (sets.isEmpty) throw StateError('No sets logged on $dateStr');

    // Insertion-ordered, so exercises keep the order they were logged in.
    final byCategory = <int, List<WorkoutSet>>{};
    for (final s in sets) {
      byCategory.putIfAbsent(s.categoryId, () => []).add(s);
    }

    return transaction(() async {
      final wId =
          await into(workouts).insert(WorkoutsCompanion.insert(name: name));
      var order = 0;
      for (final entry in byCategory.entries) {
        final reps = entry.value.map((s) => s.reps).toSet();
        await into(workoutExercises).insert(WorkoutExercisesCompanion.insert(
          workoutId:  wId,
          categoryId: entry.key,
          targetSets: Value(entry.value.length),
          targetReps: Value(reps.length == 1 ? reps.first : null),
          sortOrder:  Value(order++),
        ));
      }
      return wId;
    });
  }

  Future<int> renameWorkout(int id, String name) =>
      (update(workouts)..where((t) => t.id.equals(id)))
          .write(WorkoutsCompanion(name: Value(name)));

  Future<int> updateWorkoutNotes(int id, String notes) =>
      (update(workouts)..where((t) => t.id.equals(id)))
          .write(WorkoutsCompanion(notes: Value(notes)));

  Future<void> reorderWorkoutExercises(int workoutId, List<int> weIds) async {
    for (var i = 0; i < weIds.length; i++) {
      await (update(workoutExercises)
            ..where((t) => t.id.equals(weIds[i])))
          .write(WorkoutExercisesCompanion(sortOrder: Value(i)));
    }
  }

  /// Returns a workout containing exactly [categoryId]. If one exists it is
  /// reused, otherwise a new workout named [exerciseName] is created.
  Future<int> getOrCreateWorkoutForExercise(int categoryId, String exerciseName) async {
    // Find workouts that contain this exercise and have exactly one exercise
    final rows = await customSelect(
      'SELECT we.workout_id FROM workout_exercises we '
      'WHERE we.category_id = ? '
      'AND (SELECT COUNT(*) FROM workout_exercises we2 WHERE we2.workout_id = we.workout_id) = 1',
      variables: [Variable.withInt(categoryId)],
      readsFrom: {workoutExercises},
    ).get();
    if (rows.isNotEmpty) return rows.first.read<int>('workout_id');

    final wId = await into(workouts).insert(
        WorkoutsCompanion.insert(name: exerciseName));
    await addExerciseToWorkout(wId, categoryId);
    return wId;
  }

  /// Deletes a workout and everything scheduling it, returning the pieces so
  /// the caller can offer an undo.
  Future<DeletedWorkout?> deleteWorkout(int id) => transaction(() async {
        final workout =
            await (select(workouts)..where((t) => t.id.equals(id)))
                .getSingleOrNull();
        if (workout == null) return null;

        final assignments = await (select(planWorkouts)
              ..where((t) => t.workoutId.equals(id)))
            .get();
        final exercises = await (select(workoutExercises)
              ..where((t) => t.workoutId.equals(id)))
            .get();
        final sessions = await (select(phaseSessions)
              ..where((t) => t.workoutId.equals(id)))
            .get();
        final events = await (select(planEvents)
              ..where((t) => t.workoutId.equals(id)))
            .get();

        // Its sessions leave the rotations, but the log of doing them stays,
        // without the workout: each entry still marks the week it was done
        // in, so the weeks trained with it stay done.
        await (update(planEvents)..where((t) => t.workoutId.equals(id)))
            .write(const PlanEventsCompanion(workoutId: Value(null)));
        await (delete(phaseSessions)..where((t) => t.workoutId.equals(id))).go();
        await (delete(planWorkouts)..where((t) => t.workoutId.equals(id))).go();
        await (delete(workoutExercises)..where((t) => t.workoutId.equals(id)))
            .go();
        await (delete(workouts)..where((t) => t.id.equals(id))).go();

        return DeletedWorkout(
          workout: workout,
          exercises: exercises,
          assignments: assignments,
          sessions: sessions,
          events: events,
        );
      });

  /// Reverses [deleteWorkout].
  Future<void> restoreWorkout(DeletedWorkout deleted) => transaction(() async {
        await into(workouts).insert(deleted.workout.toCompanion(false));
        for (final e in deleted.exercises) {
          await into(workoutExercises).insert(e.toCompanion(false));
        }
        for (final a in deleted.assignments) {
          await into(planWorkouts).insert(a.toCompanion(false));
        }
        for (final s in deleted.sessions) {
          await into(phaseSessions).insert(s.toCompanion(false));
        }
        for (final e in deleted.events) {
          await (update(planEvents)..where((t) => t.id.equals(e.id)))
              .write(PlanEventsCompanion(workoutId: Value(e.workoutId)));
        }
      });

  // Returns (weId, category, targetSets, targetReps, targetRpe) per exercise in
  // the workout.
  Stream<List<(int, ExerciseCategory, int?, int?, int?)>> watchExercisesForWorkout(int workoutId) {
    final q = select(workoutExercises).join([
      innerJoin(exerciseCategories,
          exerciseCategories.id.equalsExp(workoutExercises.categoryId)),
    ])
      ..where(workoutExercises.workoutId.equals(workoutId))
      ..orderBy([
        OrderingTerm.asc(workoutExercises.sortOrder),
        OrderingTerm.asc(exerciseCategories.name),
      ]);
    return q.watch().map((rows) => rows
        .map((r) {
          final we = r.readTable(workoutExercises);
          return (
            we.id,
            r.readTable(exerciseCategories),
            we.targetSets,
            we.targetReps,
            we.targetRpe,
          );
        })
        .toList());
  }

  Future<int> updateWorkoutTarget(
          int weId, int? targetSets, int? targetReps) =>
      (update(workoutExercises)
            ..where((t) => t.id.equals(weId)))
          .write(WorkoutExercisesCompanion(
            targetSets: Value(targetSets),
            targetReps: Value(targetReps),
          ));

  /// Kept apart from [updateWorkoutTarget], which overwrites both of its
  /// fields: an RPE edit and a sets/reps edit come from different controls.
  Future<int> updateWorkoutTargetRpe(int weId, int? targetRpe) =>
      (update(workoutExercises)..where((t) => t.id.equals(weId)))
          .write(WorkoutExercisesCompanion(targetRpe: Value(targetRpe)));

  Stream<List<Workout>> watchWorkoutsForExercise(int categoryId) {
    final q = select(workoutExercises).join([
      innerJoin(workouts, workouts.id.equalsExp(workoutExercises.workoutId)),
    ])
      ..where(workoutExercises.categoryId.equals(categoryId));
    return q.watch().map((rows) =>
        rows.map((r) => r.readTable(workouts)).toList());
  }

  Future<void> addExerciseToWorkout(int workoutId, int categoryId) async {
    // Assign next sort order so new exercises appear at the end
    final maxRow = await customSelect(
      'SELECT MAX(sort_order) AS m FROM workout_exercises WHERE workout_id = ?',
      variables: [Variable.withInt(workoutId)],
    ).getSingleOrNull();
    final next = (maxRow?.readNullable<int>('m') ?? -1) + 1;
    await into(workoutExercises).insert(
      WorkoutExercisesCompanion.insert(
          workoutId: workoutId, categoryId: categoryId, sortOrder: Value(next)),
    );
  }

  Future<int> removeExerciseFromWorkout(int weId) =>
      (delete(workoutExercises)..where((t) => t.id.equals(weId))).go();

  Future<int> removeAllOfExerciseFromWorkout(int workoutId, int categoryId) =>
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

  /// Starts or stops a plan. Only one periodized plan runs at a time, so
  /// starting one stops whichever other periodized plan was running.
  Future<void> setPlanActive(int id, bool active) => transaction(() async {
        if (active && await _isPeriodized(id)) {
          await customUpdate(
            'UPDATE plans SET active = 0 WHERE id != ? AND EXISTS '
            '(SELECT 1 FROM plan_phases ph WHERE ph.plan_id = plans.id)',
            variables: [Variable.withInt(id)],
            updates: {plans},
          );
        }
        await (update(plans)..where((t) => t.id.equals(id)))
            .write(PlansCompanion(active: Value(active)));
      });

  Future<bool> _isPeriodized(int planId) async {
    final row = await (select(planPhases)
          ..where((t) => t.planId.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Deletes a plan and its assignments, returning them for undo.
  Future<DeletedPlan?> deletePlan(int id) => transaction(() async {
        final plan =
            await (select(plans)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (plan == null) return null;
        final assignments =
            await (select(planWorkouts)..where((t) => t.planId.equals(id))).get();
        final phaseIds = await (select(planPhases)
              ..where((t) => t.planId.equals(id)))
            .map((p) => p.id)
            .get();
        final phases = [
          for (final phaseId in phaseIds) (await deletePhase(phaseId))!,
        ];

        await (delete(planWorkouts)..where((t) => t.planId.equals(id))).go();
        await (delete(plans)..where((t) => t.id.equals(id))).go();

        return DeletedPlan(
            plan: plan, assignments: assignments, phases: phases);
      });

  /// Reverses [deletePlan].
  Future<void> restorePlan(DeletedPlan deleted) => transaction(() async {
        await into(plans).insert(deleted.plan.toCompanion(false));
        for (final a in deleted.assignments) {
          await into(planWorkouts).insert(a.toCompanion(false));
        }
        for (final p in deleted.phases) {
          await restorePhase(p);
        }
      });

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

  Future<void> shiftPlanDay(int planId, int weekday) async {
    await customUpdate(
      'UPDATE plan_workouts SET weekday = (weekday % 7) + 1 '
      'WHERE plan_id = ? AND weekday = ?',
      variables: [Variable.withInt(planId), Variable.withInt(weekday)],
      updates: {planWorkouts},
    );
  }

  Future<void> shiftPlanWeekFrom(int planId, int fromWeekday) async {
    await customUpdate(
      'UPDATE plan_workouts SET weekday = (weekday % 7) + 1 '
      'WHERE plan_id = ? AND weekday IS NOT NULL AND weekday >= ?',
      variables: [Variable.withInt(planId), Variable.withInt(fromWeekday)],
      updates: {planWorkouts},
    );
  }

  // ── Periodized plans ──────────────────────────────────────────────────────

  /// Appends a phase to [planId]. A plan's first phase makes it periodized;
  /// if another periodized plan is already running, this one is stopped, so
  /// drafting the next plan doesn't interrupt the current one.
  Future<int> insertPhase(int planId, String name,
          {required int lengthPasses, int? deloadEvery}) =>
      transaction(() async {
    if (!await _isPeriodized(planId)) {
      final running = await activePlan();
      if (running != null && running.plan.id != planId) {
        await (update(plans)..where((t) => t.id.equals(planId)))
            .write(const PlansCompanion(active: Value(false)));
      }
    }
    final maxRow = await customSelect(
      'SELECT MAX(sort_order) AS m FROM plan_phases WHERE plan_id = ?',
      variables: [Variable.withInt(planId)],
    ).getSingleOrNull();
    final next = (maxRow?.readNullable<int>('m') ?? -1) + 1;
    return into(planPhases).insert(PlanPhasesCompanion.insert(
      planId: planId,
      name: name,
      lengthPasses: lengthPasses,
      deloadEvery: Value(deloadEvery),
      sortOrder: Value(next),
    ));
  });

  /// Appends [workoutId] to the end of a phase's rotation.
  Future<int> addSessionToPhase(int phaseId, int workoutId) async {
    final maxRow = await customSelect(
      'SELECT MAX(sort_order) AS m FROM phase_sessions WHERE phase_id = ?',
      variables: [Variable.withInt(phaseId)],
    ).getSingleOrNull();
    final next = (maxRow?.readNullable<int>('m') ?? -1) + 1;
    return into(phaseSessions).insert(PhaseSessionsCompanion.insert(
      phaseId: phaseId,
      workoutId: workoutId,
      sortOrder: Value(next),
    ));
  }

  Stream<List<PlanPhase>> watchPlanPhases(int planId) => (select(planPhases)
        ..where((t) => t.planId.equals(planId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  /// The rotations of every phase in [planId], each in rotation order.
  Stream<List<PhaseSession>> watchPlanSessions(int planId) =>
      (select(phaseSessions)
            ..where((t) => t.phaseId.isInQuery(selectOnly(planPhases)
              ..addColumns([planPhases.id])
              ..where(planPhases.planId.equals(planId))))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<int> updatePhase(int id,
          {required String name,
          required int lengthPasses,
          required int? deloadEvery}) =>
      (update(planPhases)..where((t) => t.id.equals(id)))
          .write(PlanPhasesCompanion(
        name: Value(name),
        lengthPasses: Value(lengthPasses),
        deloadEvery: Value(deloadEvery),
      ));

  /// Puts a plan's phases in the order of [phaseIds].
  Future<void> reorderPhases(List<int> phaseIds) => transaction(() async {
        for (var i = 0; i < phaseIds.length; i++) {
          await (update(planPhases)..where((t) => t.id.equals(phaseIds[i])))
              .write(PlanPhasesCompanion(sortOrder: Value(i)));
        }
      });

  Future<int> removePhaseSession(int id) =>
      (delete(phaseSessions)..where((t) => t.id.equals(id))).go();

  /// Deletes a phase with its rotation, overrides and log, returning them
  /// for undo.
  Future<DeletedPhase?> deletePhase(int id) => transaction(() async {
        final phase = await (select(planPhases)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (phase == null) return null;
        final sessions = await (select(phaseSessions)
              ..where((t) => t.phaseId.equals(id)))
            .get();
        final targets = await (select(phaseExerciseTargets)
              ..where((t) => t.phaseId.equals(id)))
            .get();
        final events =
            await (select(planEvents)..where((t) => t.phaseId.equals(id))).get();

        await (delete(planEvents)..where((t) => t.phaseId.equals(id))).go();
        await (delete(phaseExerciseTargets)..where((t) => t.phaseId.equals(id)))
            .go();
        await (delete(phaseSessions)..where((t) => t.phaseId.equals(id))).go();
        await (delete(planPhases)..where((t) => t.id.equals(id))).go();

        return DeletedPhase(
            phase: phase, sessions: sessions, targets: targets, events: events);
      });

  /// Reverses [deletePhase].
  Future<void> restorePhase(DeletedPhase deleted) => transaction(() async {
        await into(planPhases).insert(deleted.phase.toCompanion(false));
        for (final s in deleted.sessions) {
          await into(phaseSessions).insert(s.toCompanion(false));
        }
        for (final t in deleted.targets) {
          await into(phaseExerciseTargets).insert(t.toCompanion(false));
        }
        for (final e in deleted.events) {
          await into(planEvents).insert(e.toCompanion(false));
        }
      });

  Stream<List<PhaseExerciseTarget>> watchPhaseExerciseTargets(int phaseId) =>
      (select(phaseExerciseTargets)..where((t) => t.phaseId.equals(phaseId)))
          .watch();

  /// Sets a phase's targets for one exercise, replacing any it had. Leaving
  /// every field null removes the override, so the workout's own targets
  /// apply again.
  Future<void> setPhaseExerciseTarget(int phaseId, int categoryId,
          {int? rpe, int? sets, int? reps}) =>
      transaction(() async {
        await (delete(phaseExerciseTargets)
              ..where((t) =>
                  t.phaseId.equals(phaseId) & t.categoryId.equals(categoryId)))
            .go();
        if (rpe == null && sets == null && reps == null) return;
        await into(phaseExerciseTargets).insert(
            PhaseExerciseTargetsCompanion.insert(
          phaseId: phaseId,
          categoryId: categoryId,
          targetRpe: Value(rpe),
          targetSets: Value(sets),
          targetReps: Value(reps),
        ));
      });

  /// The active periodized plan and where it stands, or null if no active
  /// plan has phases.
  Future<ActivePlan?> activePlan() async {
    final plan = await customSelect(
      'SELECT * FROM plans p WHERE p.active = 1 AND EXISTS '
      '(SELECT 1 FROM plan_phases ph WHERE ph.plan_id = p.id) '
      'ORDER BY p.id LIMIT 1',
      readsFrom: {plans, planPhases},
    ).map((r) => plans.map(r.data)).getSingleOrNull();
    if (plan == null) return null;

    final phases = await (select(planPhases)
          ..where((t) => t.planId.equals(plan.id)))
        .get();
    final sessions = await (select(phaseSessions)
          ..where((t) => t.phaseId.isIn(phases.map((p) => p.id)))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    final events = await (select(planEvents)
          ..where((t) => t.planId.equals(plan.id)))
        .get();

    final rotations = <int, List<int>>{
      for (final p in phases) p.id: [],
    };
    for (final s in sessions) {
      rotations[s.phaseId]!.add(s.workoutId);
    }
    return ActivePlan(
      plan: plan,
      phases: phases,
      rotations: rotations,
      events: events,
      state: resolvePlan(phases, rotations, events),
    );
  }

  /// [activePlan], again whenever anything it is built from changes.
  Stream<ActivePlan?> watchActivePlan() => customSelect(
        'SELECT 1',
        readsFrom: {plans, planPhases, phaseSessions, planEvents},
      ).watch().asyncMap((_) => activePlan());

  /// Marks [workoutId] done in the active plan's current pass. Returns the
  /// event (for undo), or null when the workout isn't due this pass — not in
  /// the rotation, already done, or no periodized plan running.
  Future<PlanEvent?> finishSession(int workoutId, String dateStr) =>
      _recordSession(PlanEventKind.done, workoutId, dateStr);

  /// Lets the current pass finish without [workoutId]. Null as for
  /// [finishSession].
  Future<PlanEvent?> skipSession(int workoutId, String dateStr) =>
      _recordSession(PlanEventKind.skip, workoutId, dateStr);

  /// Makes the next pass that hasn't started a deload.
  Future<PlanEvent?> deloadNow(String dateStr) =>
      _recordEvent(PlanEventKind.deload, dateStr);

  /// Moves the active plan on from its current phase, done or not.
  Future<PlanEvent?> advancePhase(String dateStr) =>
      _recordEvent(PlanEventKind.advance, dateStr);

  Future<PlanEvent?> _recordSession(
      PlanEventKind kind, int workoutId, String dateStr) async {
    final active = await activePlan();
    if (active == null || !active.state.remaining.contains(workoutId)) {
      return null;
    }
    return _insertEvent(active, kind, dateStr, workoutId: workoutId);
  }

  Future<PlanEvent?> _recordEvent(PlanEventKind kind, String dateStr) async {
    final active = await activePlan();
    if (active == null || active.state.phase == null) return null;
    return _insertEvent(active, kind, dateStr);
  }

  Future<PlanEvent> _insertEvent(
      ActivePlan active, PlanEventKind kind, String dateStr,
      {int? workoutId}) {
    return into(planEvents).insertReturning(PlanEventsCompanion.insert(
      planId: active.plan.id,
      phaseId: active.state.phase!.id,
      workoutId: Value(workoutId),
      pass: Value(workoutId == null ? null : active.state.passesDone + 1),
      closesPass: Value(workoutId != null &&
          active.state.remaining.length == 1 &&
          active.state.remaining.single == workoutId),
      dateStr: dateStr,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      kind: kind,
    ));
  }

  Future<PlanEvent?> deletePlanEvent(int id) async {
    final event = await (select(planEvents)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (event == null) return null;
    await (delete(planEvents)..where((t) => t.id.equals(id))).go();
    return event;
  }

  /// Puts an undone event back exactly as it was, id and time included, so
  /// it replays in its original place.
  Future<void> restorePlanEvent(PlanEvent event) =>
      into(planEvents).insert(event.toCompanion(false));

  // ── Home screen: planned exercises for a date ─────────────────────────────

  /// SQL condition on `pw` (a `plan_workouts` row): its plan is running and
  /// schedules by weekday and date. A periodized plan's sessions come from its
  /// rotation instead — see [activePlan].
  static const _weeklyPlan = 'pw.plan_id IN (SELECT p.id FROM plans p '
      'WHERE p.active = 1 AND NOT EXISTS '
      '(SELECT 1 FROM plan_phases ph WHERE ph.plan_id = p.id))';

  Stream<Set<int>> watchPlannedCategoryIdsForDate(String dateStr) {
    final weekday = dateFromStr(dateStr).weekday;
    return customSelect(
      'SELECT DISTINCT we.category_id FROM workout_exercises we '
      'INNER JOIN plan_workouts pw ON we.workout_id = pw.workout_id '
      'WHERE (pw.date_str = ? OR pw.weekday = ?) AND $_weeklyPlan',
      variables: [Variable.withString(dateStr), Variable.withInt(weekday)],
      readsFrom: {workoutExercises, planWorkouts, plans, planPhases},
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
      'WHERE (pw.date_str = ? OR pw.weekday = ?) AND $_weeklyPlan '
      'ORDER BY w.name, ec.name',
      variables: [Variable.withString(dateStr), Variable.withInt(weekday)],
      readsFrom: {
        planWorkouts, workouts, workoutExercises, exerciseCategories, plans,
        planPhases,
      },
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
          .map((wId) => (Workout(id: wId, name: names[wId]!, notes: ''), exMap[wId]!))
          .toList();
    });
  }

  /// An exercise's target on [dateStr], or null if nothing plans it.
  ///
  /// The running phase of a periodized plan comes first: if the exercise is in
  /// one of its sessions, that session's target applies, with the phase's
  /// override and any deload on top. Otherwise a weekly plan scheduling it on
  /// that day supplies the target as written.
  Stream<Target?> watchExerciseTarget(int categoryId, String dateStr) =>
      customSelect(
        'SELECT 1',
        readsFrom: {
          plans, planPhases, phaseSessions, planEvents, phaseExerciseTargets,
          planWorkouts, workoutExercises,
        },
      ).watch().asyncMap((_) => _exerciseTarget(categoryId, dateStr));

  Future<Target?> _exerciseTarget(int categoryId, String dateStr) async {
    final active = await activePlan();
    final phase = active?.state.phase;
    if (active != null && phase != null) {
      // Sessions still due this pass first, so the target is the one about
      // to be trained when the exercise turns up in more than one.
      final rotation = active.rotations[phase.id] ?? const <int>[];
      final remaining = active.state.remaining;
      final ordered = [
        ...remaining,
        ...rotation.where((w) => !remaining.contains(w)),
      ];
      for (final workoutId in ordered) {
        final we = await (select(workoutExercises)
              ..where((t) =>
                  t.workoutId.equals(workoutId) &
                  t.categoryId.equals(categoryId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
        if (we == null) continue;
        final override = await (select(phaseExerciseTargets)
              ..where((t) =>
                  t.phaseId.equals(phase.id) & t.categoryId.equals(categoryId))
              ..limit(1))
            .getSingleOrNull();
        return resolveTarget(
          Target(sets: we.targetSets, reps: we.targetReps, rpe: we.targetRpe),
          override,
          deload: active.state.isDeload,
        );
      }
    }

    final weekday = dateFromStr(dateStr).weekday;
    final row = await customSelect(
      'SELECT we.target_sets, we.target_reps, we.target_rpe '
      'FROM workout_exercises we '
      'JOIN plan_workouts pw ON we.workout_id = pw.workout_id '
      'WHERE we.category_id = ? AND (pw.date_str = ? OR pw.weekday = ?) '
      'AND $_weeklyPlan '
      'LIMIT 1',
      variables: [
        Variable.withInt(categoryId),
        Variable.withString(dateStr),
        Variable.withInt(weekday),
      ],
    ).getSingleOrNull();
    if (row == null) return null;
    return Target(
      sets: row.readNullable<int>('target_sets'),
      reps: row.readNullable<int>('target_reps'),
      rpe: row.readNullable<int>('target_rpe'),
    );
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

// ── Undo snapshots ───────────────────────────────────────────────────────────

/// Everything removed by [AppDatabase.deleteCategory], kept together so the
/// exercise can be put back exactly as it was.
class DeletedCategory {
  final ExerciseCategory category;
  final List<WorkoutSet> sets;
  final List<WorkoutExercise> memberships;
  final List<int> unlinkedInspirationIds;

  /// The exercise photo, so an undo puts that back too.
  final Uint8List? image;

  /// Periodized-plan phases' targets for the exercise.
  final List<PhaseExerciseTarget> phaseTargets;

  const DeletedCategory({
    required this.category,
    required this.sets,
    required this.memberships,
    required this.unlinkedInspirationIds,
    this.image,
    this.phaseTargets = const [],
  });
}

/// Thrown when a name that has to stay distinguishable is already taken.
class DuplicateNameException implements Exception {
  final String name;
  const DuplicateNameException(this.name);

  @override
  String toString() => '"$name" already exists';
}

/// Everything removed by [AppDatabase.deleteWorkout].
class DeletedWorkout {
  final Workout workout;
  final List<WorkoutExercise> exercises;
  final List<PlanWorkout> assignments;

  /// Its places in periodized-plan rotations, and the log entries that
  /// named it (kept on delete, with the workout cleared).
  final List<PhaseSession> sessions;
  final List<PlanEvent> events;

  const DeletedWorkout({
    required this.workout,
    required this.exercises,
    required this.assignments,
    this.sessions = const [],
    this.events = const [],
  });
}

/// Everything removed by [AppDatabase.deletePlan].
class DeletedPlan {
  final Plan plan;
  final List<PlanWorkout> assignments;

  final List<DeletedPhase> phases;

  const DeletedPlan({
    required this.plan,
    required this.assignments,
    this.phases = const [],
  });
}

/// Everything removed by [AppDatabase.deletePhase].
class DeletedPhase {
  final PlanPhase phase;
  final List<PhaseSession> sessions;
  final List<PhaseExerciseTarget> targets;
  final List<PlanEvent> events;

  const DeletedPhase({
    required this.phase,
    required this.sessions,
    required this.targets,
    required this.events,
  });
}

/// The active periodized plan, with what [resolvePlan] made of it.
class ActivePlan {
  final Plan plan;
  final List<PlanPhase> phases;

  /// Phase id → workout ids, in rotation order.
  final Map<int, List<int>> rotations;
  final List<PlanEvent> events;
  final PlanState state;

  const ActivePlan({
    required this.plan,
    required this.phases,
    required this.rotations,
    required this.events,
    required this.state,
  });
}
