import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimateList {
  AppAnimateList._();

  /// Applies a consistent staggered animation to a list of widgets.
  /// Automatically skips non-animatable layout containers like SizedBox, Spacer, and Divider
  /// to ensure spacing remains consistent and delays remain clean.
  static List<Widget> stagger(
    List<Widget> children, {
    Duration interval = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 800),
    double slideY = 0.15,
    double slideX = 0.0,
    bool scale = false,
  }) {
    int animatableCount = 0;

    return children.map((child) {
      // Keep spacing widgets as-is without animating or delaying
      if (child is SizedBox || child is Spacer || child is Divider) {
        return child;
      }

      final delay = interval * animatableCount;
      animatableCount++;

      var anim = child.animate().fadeIn(delay: delay, duration: duration);

      if (slideY != 0.0) {
        anim = anim.slideY(
          begin: slideY,
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }

      if (slideX != 0.0) {
        anim = anim.slideX(
          begin: slideX,
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
      }

      if (scale) {
        anim = anim.scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          delay: delay,
          duration: duration,
          curve: Curves.easeOutBack,
        );
      }

      return anim;
    }).toList();
  }
}
