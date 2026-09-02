import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/format_utils.dart';

/// The app keeps everything in a local database with no sync, so an export is
/// the only thing standing between a lost phone and a lost training history.
/// This tracks when one last happened.

const _kLastBackupKey = 'last_backup_date';
const _kSnoozeKey     = 'backup_reminder_snoozed';

/// Nag once a month, and stay quiet for a week after being dismissed.
const kBackupStaleDays  = 30;
const kBackupSnoozeDays = 7;

class BackupStatus {
  /// `yyyy-MM-dd` of the last export, or null if there has never been one.
  final String? lastBackup;
  final String? snoozedOn;

  const BackupStatus({this.lastBackup, this.snoozedOn});

  int? daysSinceBackup(DateTime now) => _daysSince(lastBackup, now);

  /// Whether to nudge: overdue (or never done) and not recently dismissed.
  bool needsReminder(DateTime now) {
    final snoozed = _daysSince(snoozedOn, now);
    if (snoozed != null && snoozed < kBackupSnoozeDays) return false;
    final since = daysSinceBackup(now);
    return since == null || since >= kBackupStaleDays;
  }

  static int? _daysSince(String? dateStr, DateTime now) {
    if (dateStr == null) return null;
    final then = dateFromStr(dateStr);
    return DateTime(now.year, now.month, now.day).difference(then).inDays;
  }
}

class BackupNotifier extends StateNotifier<BackupStatus> {
  final SharedPreferences _prefs;

  BackupNotifier(this._prefs)
      : super(BackupStatus(
          lastBackup: _prefs.getString(_kLastBackupKey),
          snoozedOn:  _prefs.getString(_kSnoozeKey),
        ));

  Future<void> recordBackup([DateTime? now]) async {
    final today = dateStrFrom(now ?? DateTime.now());
    await _prefs.setString(_kLastBackupKey, today);
    // A fresh backup clears any outstanding dismissal.
    await _prefs.remove(_kSnoozeKey);
    state = BackupStatus(lastBackup: today);
  }

  Future<void> snoozeReminder([DateTime? now]) async {
    final today = dateStrFrom(now ?? DateTime.now());
    await _prefs.setString(_kSnoozeKey, today);
    state = BackupStatus(lastBackup: state.lastBackup, snoozedOn: today);
  }
}

/// Overridden in main() with the instance opened at startup.
final prefsProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('prefsProvider must be overridden'));

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupStatus>(
        (ref) => BackupNotifier(ref.watch(prefsProvider)));
