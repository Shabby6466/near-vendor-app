import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class AppAlerts {
  AppAlerts._();

  static double _getSafeTopPadding(BuildContext context) {
    double topPadding = MediaQuery.paddingOf(context).top;
    if (topPadding == 0) {
      try {
        final view = View.of(context);
        topPadding = view.padding.top / view.devicePixelRatio;
      } catch (e) {
        debugPrint('Error getting raw view padding: $e');
      }
    }
    return topPadding + 8;
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    AlertInfo.show(
      context: context,
      text: message,
      typeInfo: TypeInfo.success,
      padding: _getSafeTopPadding(context),
      backgroundColor: isDarkBackground ? Colors.black87 : null,
      textColor: isDarkBackground ? Colors.white : null,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    AlertInfo.show(
      context: context,
      text: message,
      typeInfo: TypeInfo.error,
      padding: _getSafeTopPadding(context),
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
    AlertInfo.show(
      context: context,
      text: message,
      padding: _getSafeTopPadding(context),
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
