import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class AppPinCodeField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;
  final FormFieldValidator<String>? validator;
  final double fieldWidth;
  final double fieldHeight;
  final TextStyle? textStyle;

  const AppPinCodeField({
    super.key,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.fieldWidth = 50,
    this.fieldHeight = 56,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: fieldWidth,
      height: fieldHeight,
      textStyle:
          textStyle ??
          TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: theme.primaryColor, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      onChanged: onChanged,
      onCompleted: onCompleted,
      validator: validator,
      cursor: Container(height: 24, width: 2, color: theme.primaryColor),
    );
  }
}
