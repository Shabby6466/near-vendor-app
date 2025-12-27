import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class AppContainer extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;
  final double? borderRadius;
  final Color? color;
  final double? width;

  const AppContainer({
    super.key,
    this.padding,
    required this.child,
    this.borderRadius,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.mediumHorizontalSpacing(context),
            vertical: AppSpacing.mediumVerticalSpacing(context),
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        color: color ?? ColorName.secondary.shade400,
      ),
      child: child,
    );
  }
}
