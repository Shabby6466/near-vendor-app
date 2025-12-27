import 'package:flutter/material.dart';
import 'package:toasty_box/toast_service.dart';

class AppAlerts {
  AppAlerts._();

  static void showErrorSnackBar(BuildContext context, [String? message]) {
    ToastService.showErrorToast(
      context,
      message: message ?? "Something went wrong",
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ToastService.showSuccessToast(
      context,
      message: message,
    );
  }
}
