import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const AuthTextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
        vertical: 4,
      ),
      width: AppSpacing.screenWidth(context),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: (0.05))
            : Colors.white.withValues(alpha: (0.9)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: (0.1)),
          width: 1,
        ),
      ),
      child: AppTextField(
        controller: controller,
        hint: label,
        isPassword: isPassword,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
