import 'package:flutter/material.dart';

class ScanningArea extends StatelessWidget {
  final Animation<double> scannerAnimation;

  const ScanningArea({
    super.key,
    required this.scannerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final areaWidth = size.width * 0.75;
    final areaHeight = size.height * 0.45;

    return Container(
      width: areaWidth,
      height: areaHeight,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Scanning Line
          AnimatedBuilder(
            animation: scannerAnimation,
            builder: (context, child) {
              return Positioned(
                top: scannerAnimation.value * (areaHeight - 2),
                left: 10,
                right: 10,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.8),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue,
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Corners
          Positioned(
            top: 20,
            left: 20,
            child: _ScanningCorner(isTop: true, isLeft: true),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _ScanningCorner(isTop: true, isLeft: false),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _ScanningCorner(isTop: false, isLeft: true),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _ScanningCorner(isTop: false, isLeft: false),
          ),
        ],
      ),
    );
  }
}

class _ScanningCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _ScanningCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.blue, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.blue, width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.blue, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.blue, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
