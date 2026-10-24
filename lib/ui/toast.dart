import 'package:flutter/material.dart';

/// Short-lived confirmations ("Copied", "Bookmark removed", ...).
extension Toast on ScaffoldMessengerState {
  static const duration = Duration(seconds: 3);

  /// Replaces any visible snackbar (so they never queue up) and hides itself
  /// after [duration], even with an [action]: Flutter otherwise keeps
  /// snackbars that have an action on screen until dismissed.
  void showToast(String message, {SnackBarAction? action}) {
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        persist: false,
      ),
    );
  }
}
