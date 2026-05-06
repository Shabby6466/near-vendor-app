import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppLoadingIndicator({super.key, this.size = 28, this.strokeWidth = 3});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.1,
            ),
          ),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: LoadingAnimation(color: ColorName.primary),
        ),
      ),
    );
  }
}
