import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: onSurface.withValues(alpha: 0.08)),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AppTextField(
          controller: controller,
          hint: label.toUpperCase(),
          isPassword: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.3,
            color: onSurface,
          ),
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: onSurface.withValues(alpha: 0.35),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: onSurface.withValues(alpha: 0.1),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: onSurface.withValues(alpha: 0.6),
                  )
                : null,
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.5,
              ),
            ),
            hintText: label.toUpperCase(),
          ),
        ),
      ),
    );
  }
}
