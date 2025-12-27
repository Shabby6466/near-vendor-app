import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:nearvendorapp/gen/colors.gen.dart';

class AppDialog {
  AppDialog._();

  static void showDialog({
    String? label,
    required Widget child,
    required BuildContext context,
  }) {
    showGeneralDialog(
      context: context,
      barrierLabel: label,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.19),
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
