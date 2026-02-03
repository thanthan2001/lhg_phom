import 'package:flutter/material.dart';
import 'package:get/get.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppSnackbar {
  static void show(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint('[${title}] $message');
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin:
              snackPosition == SnackPosition.TOP
                  ? const EdgeInsets.fromLTRB(16, 24, 16, 0)
                  : const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
  }
}
