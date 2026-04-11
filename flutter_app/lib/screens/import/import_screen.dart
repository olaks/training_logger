import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' as io;
import '../../providers/app_providers.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

enum _Step { idle, preview, importing, done }

class _ImportScreenState extends ConsumerState<ImportScreen> {
  _Step _step = _Step.idle;
  List<Map<String, String>> _rows = [];
  int _importedCount = 0;
  String? _error;

  // Derived stats shown in preview
  int get _exerciseCount =>
      _rows.map((r) => r['Exercise'] ?? '').toSet().length;
  String get _dateRange {
    final dates = _rows
        .map((r) => r['Date'] ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (dates.isEmpty) return '—';
    if (dates.length == 1) return dates.first;
    return '${dates.first}  →  ${dates.last}';
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: kIsWeb,      // web needs bytes in-memory
      withReadStream: false,
    );
    if (result == null) return;

    try {
      String csv;
      if (kIsWeb) {
        csv = utf8.decode(result.files.single.bytes!);
      } else {
        csv = await io.File(result.files.single.path!).readAsString();
      }
      final rows = _parseCsv(csv);
      if (rows.isEmpty) throw 'No data rows found in file.';
      setState(() {
        _rows = rows;
        _step = _Step.preview;
      });
    } catch (e) {
      setState(() => _error = 'Could not read file: $e');
    }
  }

  Future<void> _import() async {
    setState(() => _step = _Step.importing);
    try {
      final count = await ref.read(dbProvider).importFitNotes(_rows);
      setState(() {
        _importedCount = count;
        _step = _Step.done;
      });
    } catch (e) {
      setState(() {
        _error = 'Import failed: $e';
        _step = _Step.preview;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import FitNotes CSV',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (_step) {
          _Step.idle     => _buildIdle(),
          _Step.preview  => _buildPreview(),
          _Step.importing => _buildImporting(),
          _Step.done     => _buildDone(),
        },
      ),
    );
  }

  Widget _buildIdle() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.upload_file,
              size: 72,
              color: Colors.white.withValues(alpha:0.15)),
          const SizedBox(height: 20),
          Text('Select the CSV you exported from FitNotes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha:0.5))),
          const SizedBox(height: 8),
          Text('FitNotes → Settings → Backup & Restore → Export as CSV',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha:0.3))),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('Pick CSV File'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ],
        ],
      );

  Widget _buildPreview() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatRow(label: 'Sets to import', value: '${_rows.length}'),
          _StatRow(label: 'Exercises',      value: '$_exerciseCount'),
          _StatRow(label: 'Date range',     value: _dateRange),
          const SizedBox(height: 8),
          Text(
            'Existing exercises with the same name will be reused. '
            'Re-importing the same file will create duplicate entries.',
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha:0.4)),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _rows = [];
                    _step = _Step.idle;
                    _error = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _import,
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildImporting() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Importing…'),
          ],
        ),
      );

  Widget _buildDone() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.check_circle_outline,
              size: 72,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text('Imported $_importedCount sets',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      );

  // ── CSV parsing ───────────────────────────────────────────────────────────

  static List<Map<String, String>> _parseCsv(String csv) {
    // Normalise line endings
    final lines = csv.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    if (lines.isEmpty) return [];

    final headers = _splitLine(lines[0]);
    final rows = <Map<String, String>>[];

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final values = _splitLine(line);
      final row = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        row[headers[i]] = i < values.length ? values[i] : '';
      }
      rows.add(row);
    }
    return rows;
  }

  // Handles quoted fields (e.g. "Smith, John") and plain comma-separated values
  static List<String> _splitLine(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        fields.add(buf.toString().trim());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    fields.add(buf.toString().trim());
    return fields;
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(color: Colors.white.withValues(alpha:0.6))),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      );
}
