import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class OnboardingBtns extends StatelessWidget {
  final String btnText;
  final VoidCallback onTap;
  final BorderRadiusGeometry? borderRadius;
  const OnboardingBtns({
    super.key,
    required this.btnText,
    required this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.mediumVerticalSpacing(context) * 0.75,
          horizontal: AppSpacing.mediumHorizontalSpacing(context) * 0.9,
        ),
        decoration: BoxDecoration(
          color: ColorName.secondary.shade400,
          borderRadius: borderRadius,
        ),
        child: Text(
          btnText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
