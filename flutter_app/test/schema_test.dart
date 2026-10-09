import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/database/database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v16.dart' as v16;
import 'generated_migrations/schema_v17.dart' as v17;
import 'generated_migrations/schema_v18.dart' as v18;

/// The migration chain is the one place a bug destroys data that no backup
/// inside the app can recover, so these check the schema drift actually ends
/// up with — not just that the migration ran without throwing.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    dir = Directory.systemTemp.createTempSync('training_logger_schema');
    file = File('${dir.path}/db.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a fresh database matches what the generated code expects', () async {
    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.validateDatabaseSchema();
    await db.close();
  });

  test('upgrading from v15 lands on the same schema as a fresh install',
      () async {
    // v16 changed no tables, so a v16 database marked as v15 has the right
    // shape — only the version has to move.
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(16);
    final old = v16.DatabaseAtV16(schema.newConnection());
    await old.customStatement(
        "INSERT INTO exercise_categories (name) VALUES ('Bench')");
    await old.customStatement('PRAGMA user_version = 15');
    await old.close();

    final upgraded = AppDatabase.forTesting(schema.newConnection());
    await upgraded.validateDatabaseSchema();
    expect((await upgraded.watchAllCategories().first).map((c) => c.name),
        contains('Bench'),
        reason: 'the migration must not lose rows');
    await upgraded.close();
  });

  test('v16 exercise photos survive the move into their own table', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(16);

    // The generated historical schema exposes tables but no companions, so
    // the v16 rows go in as plain SQL.
    final old = v16.DatabaseAtV16(schema.newConnection());
    await old.customStatement(
      'INSERT INTO exercise_categories (id, name, image_data) '
      'VALUES (1, ?, ?)',
      ['Dead Hang', Uint8List.fromList([1, 2, 3, 4])],
    );
    await old.customStatement(
        'INSERT INTO exercise_categories (id, name) VALUES (2, ?)',
        ['Pull Up']);
    await old.close();
    const catId = 1;

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, db.schemaVersion);

    expect(await db.getCategoryImage(catId), [1, 2, 3, 4],
        reason: 'a photo stored on the category row must end up in the '
            'image table, not be dropped with the column');
    expect((await db.watchAllCategories().first).map((c) => c.name),
        containsAll(['Dead Hang', 'Pull Up']));
    await db.close();
  });

  test('the indexes a fresh install creates are the ones a migration adds',
      () async {
    Future<List<String>> indexesOf(AppDatabase db) async {
      final rows = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      ).get();
      return rows.map((r) => r.read<String>('name')).toList();
    }

    final fresh = AppDatabase.forTesting(NativeDatabase.memory());
    final expected = await indexesOf(fresh);
    await fresh.close();
    expect(expected, isNotEmpty);

    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(16);
    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, db.schemaVersion);
    expect(await indexesOf(db), expected);
    await db.close();
  });

  test('v17 plans come through the upgrade active, with their workouts',
      () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(17);

    final old = v17.DatabaseAtV17(schema.newConnection());
    await old.customStatement("INSERT INTO plans (id, name) VALUES (1, 'Week')");
    await old.customStatement("INSERT INTO workouts (id, name) VALUES (1, 'Push')");
    await old.customStatement(
        'INSERT INTO plan_workouts (plan_id, workout_id, weekday) '
        'VALUES (1, 1, 3)');
    await old.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, db.schemaVersion);

    final plan = (await db.watchAllPlans().first).single;
    expect(plan.name, 'Week');
    expect(plan.active, isTrue,
        reason: 'a plan that was scheduling workouts must keep doing so');
    expect((await db.watchPlanWorkouts(1).first).single.weekday, 3);
    await db.close();
  });

  test('a v18 plan in progress becomes a one-day cycle and stays where it was',
      () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(18);

    // A rotation of A and B: the first pass done (B closing it), then A of
    // the second. A weekly plan beside it has no phases.
    final old = v18.DatabaseAtV18(schema.newConnection());
    for (final sql in [
      "INSERT INTO plans (id, name, active) VALUES (1, 'Year', 1)",
      "INSERT INTO plans (id, name, active) VALUES (2, 'Week', 1)",
      "INSERT INTO workouts (id, name) VALUES (1, 'A')",
      "INSERT INTO workouts (id, name) VALUES (2, 'B')",
      'INSERT INTO plan_phases (id, plan_id, sort_order, name, length_passes) '
          "VALUES (1, 1, 0, 'Capacity', 3)",
      'INSERT INTO phase_sessions (phase_id, workout_id, sort_order) '
          'VALUES (1, 1, 0), (1, 2, 1)',
      'INSERT INTO plan_events (plan_id, phase_id, workout_id, pass, '
          'closes_pass, date_str, timestamp, kind) VALUES '
          "(1, 1, 1, 1, 0, '2026-10-01', 1, 0), "
          "(1, 1, 2, 1, 1, '2026-10-03', 2, 0), "
          "(1, 1, 1, 2, 0, '2026-10-05', 3, 0)",
    ]) {
      await old.customStatement(sql);
    }
    await old.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, db.schemaVersion);

    final plans = {
      for (final p in await db.watchAllPlans().first) p.name: p.cycleDays,
    };
    expect(plans, {'Year': 1, 'Week': 8},
        reason: 'only a periodized plan becomes a one-day cycle');
    expect((await db.watchPlanSessions(1).first).map((s) => s.day), [1, 1]);
    final events = await db.watchPlanEvents(1).first;
    expect(events.map((e) => (e.day, e.closesDay)),
        unorderedEquals([(1, false), (1, true), (1, false)]));

    final state = (await db.activePlan())!.state;
    expect((state.pass, state.day), (2, 1),
        reason: 'the plan must resolve where it stood before the upgrade');
    expect(state.remaining, [2]);
    await db.close();
  });
}
