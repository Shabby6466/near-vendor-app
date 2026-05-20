import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/location_picker_launcher.dart';

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    EdgeInsets padding = const EdgeInsets.all(24),
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      useSafeArea: true,
      enableDrag: isDismissible,
      isScrollControlled: isScrollControlled,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: ColorName.primary.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.19)),
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),

                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> showScrollableBottomSheet<T>({
    required BuildContext context,
    double minChildSize = 0.8,
    Widget Function(BuildContext context, ScrollController scrollController)?
    builder,
    bool isDismissible = true,
    bool showScrollHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: minChildSize + 0.1,
            minChildSize: minChildSize,
            expand: false,
            builder: (_, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.1, sigmaY: 20.1),
                  child: Material(
                    color: Colors.transparent,

                    child: Container(
                      padding: showScrollHandle
                          ? EdgeInsets.symmetric(
                              vertical: AppSpacing.mediumVerticalSpacing(
                                context,
                              ),
                            )
                          : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: ColorName.primary.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.19),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showScrollHandle)
                            Container(
                              height: 6,
                              width: MediaQuery.of(context).size.width * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          if (builder != null)
                            Flexible(child: builder(context, scrollController)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Future<void> showConfirmationBottomSheet({
    required BuildContext context,
    required String title,
    String subtitle = '',
    String message = '',
    String confirmButtonText = 'Continue',
    String cancelButtonText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
  }) {
    return showBottomSheet(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 22,
              letterSpacing: -0.5,
              fontFamily: 'Poppins',
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              confirmButtonText,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: Text(
              cancelButtonText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Future<void> openLocationSet() {
    final context = navigatorKey.currentContext;
    if (context == null) return Future.value();
    return LocationPickerLauncher.open(context);
  }
}
