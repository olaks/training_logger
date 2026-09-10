import 'package:flutter/material.dart';

/// Confirms a deletion with a way back out of it.
///
/// Deletions in this app are immediate — there is no trash — so the snackbar
/// is the only chance to take one back.
///
/// `persist: false` is load-bearing: a `SnackBar` carrying an action now
/// defaults to persisting, so without it the bar sits on screen for the rest
/// of the session — it belongs to the app-level messenger, so navigating away
/// doesn't clear it either. The undo is an offer, not a prompt; ignoring it
/// should let it fade.
void showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required VoidCallback onUndo,
}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 6),
    persist: false,
    action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
  ));
}
