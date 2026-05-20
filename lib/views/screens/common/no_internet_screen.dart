import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoInternetScreen({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                  ]
                : [Colors.white, const Color(0xFFF0F2F5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: theme.primaryColor,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 2.seconds,
                  color: theme.primaryColor.withValues(alpha: 0.2),
                )
                .shake(hz: 2, curve: Curves.easeInOut),

            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),

            Text(
              'No Connection',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            Text(
              'Please check your internet settings and try again to continue shopping.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            SizedBox(height: AppSpacing.largeVerticalSpacing(context) * 1.5),

            AppElevatedButton(
              text: 'Try Again',
              onPressed: onRetry,
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                // Open settings or just a passive message
              },
              child: Text(
                'Settings',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
