import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:training_logger/database/database.dart';

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
}
