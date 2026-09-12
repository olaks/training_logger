import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:training_logger/database/database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v16.dart' as v16;

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
    // Build the file, then rewind it to look like a v15 database. v16 changed
    // no tables, so the shape is right — only the version has to move.
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    await fresh.insertOrGetCategory('Bench');
    await fresh.close();

    final raw = sqlite3.open(file.path);
    raw.execute('PRAGMA user_version = 15');
    raw.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
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
    await verifier.migrateAndValidate(db, 17);

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
    await verifier.migrateAndValidate(db, 17);
    expect(await indexesOf(db), expected);
    await db.close();
  });
}
