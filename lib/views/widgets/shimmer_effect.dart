import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerEffect extends StatelessWidget {
  final double borderRadius;
  const ShimmerEffect({super.key, this.borderRadius = 28});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(milliseconds: 200),
      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.white,
      colorOpacity: isDark ? 0.1 : 0.3,
      enabled: true,
      direction: const ShimmerDirection.fromLBRT(),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
