import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const AuthTextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
        vertical: AppSpacing.smallVerticalSpacing(context) * 0.5,
      ),
      width: AppSpacing.screenWidth(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hint: label,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
