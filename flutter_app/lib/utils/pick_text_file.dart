import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Asks for a single `.$extension` file and returns its contents, or null if
/// the picker was dismissed.
///
/// Reads the bytes rather than opening a path: that is the one approach that
/// works the same on web as on Android, iOS and desktop, so the callers don't
/// need a platform branch.
Future<String?> pickTextFile({required String extension}) async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: [extension],
  );
  if (files.isEmpty) return null;
  return utf8.decode(await files.single.readAsBytes());
}
