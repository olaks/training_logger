
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../providers/backup_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_utils.dart';
import '../../utils/pick_text_file.dart';
import '../../utils/share_file.dart';

/// One home for the things that apply to the whole app — above all, getting
/// the data out. Everything lives on one device in one SQLite file, so the
/// backup section leads.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final status    = ref.watch(backupProvider);
    final themeIdx  = ref.watch(themeIndexProvider);
    final hasData   = (ref.watch(workoutDatesProvider).value ?? []).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _SectionLabel('BACKUP'),
          _BackupStatusCard(status: status, hasData: hasData),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export backup'),
            subtitle: const Text('Everything, as a JSON file you keep'),
            enabled: !_busy,
            onTap: _exportBackup,
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import backup'),
            subtitle: const Text('Merge a previously exported file'),
            enabled: !_busy,
            onTap: _importBackup,
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import FitNotes CSV'),
            subtitle: const Text('Bring history over from FitNotes'),
            enabled: !_busy,
            onTap: () => context.push('/import'),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          const Divider(height: 32),
          const _SectionLabel('APPEARANCE'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: AccentPicker(
              selected: themeIdx,
              onSelect: (i) =>
                  ref.read(themeIndexProvider.notifier).setTheme(i),
            ),
          ),

          const Divider(height: 32),
          const _SectionLabel('ELSEWHERE'),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Inspirations'),
            subtitle: const Text('Saved videos and links'),
            onTap: () => context.push('/inspirations'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final json = await ref.read(dbProvider).exportToJson();
      final filename = 'training_logger_${dateStrFrom(DateTime.now())}.json';
      await shareJsonFile(json, filename);
      await ref.read(backupProvider.notifier).recordBackup();
      messenger.showSnackBar(const SnackBar(content: Text('Backup exported')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final jsonStr = await pickTextFile(extension: 'json');
    if (jsonStr == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final count = await ref.read(dbProvider).importFromJson(jsonStr);
      messenger.showSnackBar(SnackBar(content: Text('Imported $count sets')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ── Backup status ─────────────────────────────────────────────────────────────

class _BackupStatusCard extends StatelessWidget {
  final BackupStatus status;
  final bool hasData;
  const _BackupStatusCard({required this.status, required this.hasData});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final days  = status.daysSinceBackup(now);
    final stale = hasData && (days == null || days >= kBackupStaleDays);
    final color = stale
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(stale ? Icons.warning_amber_rounded : Icons.check_circle,
                size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                backupStatusText(status, now, hasData),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain-language summary of how exposed the data currently is.
String backupStatusText(BackupStatus status, DateTime now, bool hasData) {
  final days = status.daysSinceBackup(now);
  if (days == null) {
    return hasData
        ? 'Never backed up. This device holds the only copy of your training '
            'history.'
        : 'Nothing logged yet — nothing to back up.';
  }
  if (days == 0) return 'Backed up today.';
  if (days == 1) return 'Backed up yesterday.';
  if (days < kBackupStaleDays) return 'Backed up $days days ago.';
  return 'Last backup was $days days ago. Anything logged since then exists '
      'only on this device.';
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary)),
      );
}

/// The four accent colours, as a row of swatches.
class AccentPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const AccentPicker({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(themeAccents.length, (i) {
          final accent = themeAccents[i];
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.15),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 22)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(accent.name,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          );
        }),
      );
}
