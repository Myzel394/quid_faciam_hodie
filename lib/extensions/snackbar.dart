import 'package:flutter/material.dart';
import 'package:share_location/constants/values.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

extension ShowSnackBar on BuildContext {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      pendingSnackBar;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    required final String message,
    final Color backgroundColor = Colors.white,
    final Duration duration = const Duration(seconds: 4),
  }) {
    pendingSnackBar?.close();
    pendingSnackBar = null;

    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  void showErrorSnackBar({required final String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  void showSuccessSnackBar({required final String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  void showPendingSnackBar({required final String message}) {
    pendingSnackBar = showSnackBar(
      message: message,
      backgroundColor: Colors.yellow,
      duration: DURATION_INFINITY,
    );
  }
}
