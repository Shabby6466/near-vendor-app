import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';

class AnimatedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;
  final IconData icon;

  const AnimatedErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Oops, something went wrong',
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine friendly message from raw exception
    String displayMessage = message;
    if (message.contains('Connection refused') || message.contains('SocketException')) {
      displayMessage = 'We could not reach the server. Please check your internet connection or try again later.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon with Glow
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds)
                 .fade(begin: 0.5, end: 1.0, duration: 2.seconds),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A1C1E) : const Color(0xFFFFF0F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ],
            )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 32),
            
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms, delay: 100.ms),
            
            const SizedBox(height: 12),
            
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Try Again', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.2,
                )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
