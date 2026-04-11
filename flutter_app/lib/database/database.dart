import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [ExerciseCategories, WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(
    name: 'training_logger',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(exerciseCategories, exerciseCategories.imageData);
      }
      if (from < 3) {
        await m.addColumn(exerciseCategories, exerciseCategories.groupName);
      }
    },
  );

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

  /// Returns number of sets inserted (skips duplicates by timestamp).
  Future<int> importFromJson(String jsonStr) async {
    final data      = jsonDecode(jsonStr) as Map<String, dynamic>;
    final exercises = (data['exercises'] as List).cast<Map<String, dynamic>>();
    int inserted    = 0;

    await transaction(() async {
      for (final ex in exercises) {
        final name     = ex['name']  as String;
        final group    = ex['group'] as String?;
        final imageB64 = ex['image'] as String?;

        // Get or create exercise
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
          // Fill in missing group / image
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
          // Skip duplicates
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

  /// Parses and inserts FitNotes CSV rows in a single transaction.
  /// Returns the number of sets inserted.
  Future<int> importFitNotes(List<Map<String, String>> rows) async {
    int inserted = 0;
    await transaction(() async {
      // Cache exercise name → id to avoid repeated lookups
      final cache = <String, int>{};

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final exerciseName = row['Exercise'] ?? '';
        if (exerciseName.isEmpty) continue;

        final groupName = _nullIfEmpty(row['Category']);
        final dateStr   = row['Date'] ?? '';
        if (dateStr.isEmpty) continue;

        // Weight: convert lbs → kg if needed
        double? weightKg;
        final wStr  = row['Weight'] ?? '';
        final wUnit = (row['Weight Unit'] ?? '').toLowerCase();
        if (wStr.isNotEmpty) {
          final w = double.tryParse(wStr);
          if (w != null && w > 0) {
            weightKg = wUnit == 'lbs' ? w / 2.20462 : w;
          }
        }

        // Reps
        int? reps;
        final rStr = row['Reps'] ?? '';
        if (rStr.isNotEmpty) {
          final r = int.tryParse(rStr);
          if (r != null && r > 0) reps = r;
        }

        // Time: FitNotes format is H:MM:SS
        int? timeSecs;
        final tStr = row['Time'] ?? '';
        if (tStr.isNotEmpty) {
          timeSecs = _parseTime(tStr);
        }

        if (weightKg == null && reps == null && timeSecs == null) continue;

        // Get or create exercise
        if (!cache.containsKey(exerciseName)) {
          final existing = await (select(exerciseCategories)
                ..where((t) => t.name.equals(exerciseName)))
              .getSingleOrNull();
          if (existing != null) {
            cache[exerciseName] = existing.id;
            // Fill in groupName if not set yet
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

        // Use date epoch + row index as timestamp to preserve order
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
