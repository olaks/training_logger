import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> shareJsonFile(String content, String filename) async {
  final bytes = utf8.encode(content);
  // ignore: deprecated_member_use
  final blob  = html.Blob([bytes], 'application/json');
  // ignore: deprecated_member_use
  final url   = html.Url.createObjectUrlFromBlob(blob);
  // ignore: deprecated_member_use
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  // ignore: deprecated_member_use
  html.Url.revokeObjectUrl(url);
}
