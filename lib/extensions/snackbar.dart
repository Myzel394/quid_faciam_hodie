import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

extension ShowSnackBar on BuildContext {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      pendingSnackBar;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar({
    required final String message,
    final Color backgroundColor = Colors.white,
    final Duration duration = const Duration(seconds: 4),
    final BuildContext? context,
  }) {
    if (!isMaterial(context ?? this)) {
      // Not implemented yet
      return null;
    }

    pendingSnackBar?.close();
    pendingSnackBar = null;

    return ScaffoldMessenger.of(context ?? this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  showToast({
    required final String message,
    final Toast toastLength = Toast.LENGTH_SHORT,
    final Color backgroundColor = Colors.white,
    final Color textColor = Colors.black,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  void showErrorSnackBar({
    required final String message,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(milliseconds: 550),
    );
  }

  void showLongErrorSnackBar({
    required final String message,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 6),
    );
  }

  void showSuccessSnackBar({
    required final String message,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      duration: const Duration(milliseconds: 550),
    );
  }

  void showPendingSnackBar({
    required final String message,
  }) {
    pendingSnackBar = showSnackBar(
      message: message,
      backgroundColor: Colors.yellow,
      duration: DURATION_INFINITY,
    );
  }

  void showSuccessToast({
    required final String message,
  }) {
    showToast(
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void showErrorToast({
    required final String message,
  }) {
    showToast(
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
