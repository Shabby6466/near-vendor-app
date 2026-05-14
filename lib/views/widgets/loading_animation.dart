import 'dart:math' as math;

import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingAnimation({super.key, this.color, this.size = 24});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: List.generate(8, (index) {
              final double position = index / 8;
              final double angle = position * 2 * math.pi;

              // Calculate opacity based on controller value and dot position
              final double opacity = ((_controller.value - position + 1) % 1)
                  .clamp(0.2, 1.0);

              return Align(
                alignment: Alignment(math.cos(angle), math.sin(angle)),
                child: Container(
                  width: widget.size * 0.22,
                  height: widget.size * 0.22,
                  decoration: BoxDecoration(
                    color: (widget.color ?? Colors.white).withValues(
                      alpha: opacity,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
