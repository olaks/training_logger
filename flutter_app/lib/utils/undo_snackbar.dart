import 'package:flutter/material.dart';

/// Confirms a deletion with a way back out of it.
///
/// Deletions in this app are immediate — there is no trash — so the snackbar
/// is the only chance to take one back.
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required VoidCallback onUndo,
}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 6),
    action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
  ));
}
