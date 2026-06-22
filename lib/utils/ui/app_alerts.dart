import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class AppAlerts {
  AppAlerts._();

  static void showSuccess(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    final topPadding = MediaQuery.of(context).padding.top + 8;
    AlertInfo.show(
      context: context,
      text: message,
      typeInfo: TypeInfo.success,
      padding: topPadding,
      backgroundColor: isDarkBackground ? Colors.black87 : null,
      textColor: isDarkBackground ? Colors.white : null,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    final topPadding = MediaQuery.of(context).padding.top + 8;
    AlertInfo.show(
      context: context,
      text: message,
      typeInfo: TypeInfo.error,
      padding: topPadding,
      backgroundColor: isDarkBackground ? Colors.black87 : null,
      textColor: isDarkBackground ? Colors.white : null,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String title = "Notification",
    bool isDarkBackground = false,
  }) {
    final topPadding = MediaQuery.of(context).padding.top + 8;
    AlertInfo.show(
      context: context,
      text: message,
      padding: topPadding,
      backgroundColor: isDarkBackground ? Colors.black87 : null,
      textColor: isDarkBackground ? Colors.white : null,
    );
  }

  static Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
    bool isDestructive = true,
  }) {
    return AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: title,
      message: message,
      confirmButtonText: confirmLabel ?? "Confirm",
      onConfirm: onConfirm,
      confirmButtonColor: isDestructive
          ? const Color(0xFFEF5350)
          : const Color(0xFF4CAF50),
      icon: isDestructive
          ? Icons.warning_amber_rounded
          : Icons.check_circle_rounded,
      iconColor: isDestructive
          ? const Color(0xFFEF5350)
          : const Color(0xFF4CAF50),
    );
  }
}
