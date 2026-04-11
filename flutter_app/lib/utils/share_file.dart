// Conditional export: web uses dart:html download, native uses share_plus.
export 'share_file_io.dart' if (dart.library.html) 'share_file_web.dart';
