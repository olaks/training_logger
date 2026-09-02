import 'package:flutter_test/flutter_test.dart';
import 'package:training_logger/providers/backup_provider.dart';

void main() {
  final now = DateTime(2026, 9, 1);

  group('needsReminder', () {
    test('nags when nothing has ever been exported', () {
      expect(const BackupStatus().needsReminder(now), isTrue);
    });

    test('stays quiet while a backup is recent', () {
      expect(
          BackupStatus(lastBackup: '2026-08-25').needsReminder(now), isFalse);
    });

    test('speaks up once a backup is a month behind', () {
      expect(BackupStatus(lastBackup: '2026-08-01').needsReminder(now), isTrue);
    });

    test('honours a dismissal for a week, then returns', () {
      expect(
          BackupStatus(lastBackup: '2026-01-01', snoozedOn: '2026-08-28')
              .needsReminder(now),
          isFalse);
      expect(
          BackupStatus(lastBackup: '2026-01-01', snoozedOn: '2026-08-20')
              .needsReminder(now),
          isTrue);
    });
  });

  group('daysSinceBackup', () {
    test('counts whole days', () {
      expect(BackupStatus(lastBackup: '2026-08-30').daysSinceBackup(now), 2);
      expect(BackupStatus(lastBackup: '2026-09-01').daysSinceBackup(now), 0);
    });

    test('has no answer before the first backup', () {
      expect(const BackupStatus().daysSinceBackup(now), isNull);
    });
  });
}
