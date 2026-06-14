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
        ),
      ),
    );
  }
}
