import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Asks for a single `.$extension` file and returns its contents, or null if
/// the picker was dismissed.
///
/// Web has no file paths, so it takes the bytes the picker holds in memory;
/// everywhere else it reads the file off disk.
Future<String?> pickTextFile({required String extension}) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: [extension],
    withData: kIsWeb,
    withReadStream: false,
  );
  if (result == null) return null;

  final file = result.files.single;
  if (kIsWeb) return utf8.decode(file.bytes!);
  return io.File(file.path!).readAsString();
}
