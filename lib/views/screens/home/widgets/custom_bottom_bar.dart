import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';

class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  bool _isDragging = false;
  double _dragX = 0;
  double _velocity = 0;
  double _lastDragX = 0;

  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;
    widget.onTap(index);
    HapticFeedback.selectionClick();
  }

  void _handleInteraction(
    Offset localPosition,
    double totalWidth, {
    required bool isDragging,
  }) {
    final itemWidth = totalWidth / 4;
    final newDragX = localPosition.dx.clamp(8.0, totalWidth - 8.0);
    final currentVelocity = isDragging ? (newDragX - _lastDragX).abs() : 0.0;

    setState(() {
      _isDragging = isDragging;
      _dragX = newDragX;
      _velocity = isDragging ? (_velocity * 0.8 + currentVelocity * 0.2) : 0.0;
      _lastDragX = newDragX;
    });

    final int index = (newDragX / itemWidth).floor().clamp(0, 3);
    if (index != widget.currentIndex) {
      _onItemTapped(index);
    }
  }

  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
      _velocity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barHeight = _isDragging ? 66.0 : 65.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AnimatedScale(
        scale: _isDragging ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        child: _GlassContainer(
          height: barHeight,
          borderRadius: BorderRadius.circular(32),
          isDark: isDark,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / 4;
              final bool isNavSelected = widget.currentIndex < 4;
              final baseDropletWidth = itemWidth - 16;
              final velocityStretch = (_velocity * 0.8).clamp(0.0, 30.0);
              final dropletWidth = baseDropletWidth + velocityStretch;

              final targetLeft =
                  (widget.currentIndex * itemWidth) + 8 - (velocityStretch / 2);
              final currentLeft = _isDragging
                  ? (_dragX - (dropletWidth / 2)).clamp(
                      8.0,
                      totalWidth - dropletWidth - 8.0,
                    )
                  : targetLeft;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) =>
                    setState(() => _isDragging = true),
                onHorizontalDragUpdate: (details) => _handleInteraction(
                  details.localPosition,
                  totalWidth,
                  isDragging: true,
                ),
                onHorizontalDragEnd: (_) => _handleDragEnd(),
                onTapDown: (details) => _handleInteraction(
                  details.localPosition,
                  totalWidth,
                  isDragging: false,
                ),
                onTapUp: (_) => _handleDragEnd(),
                child: Stack(
                  children: [
                    if (isNavSelected)
                      AnimatedPositioned(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 500),
                        curve: _isDragging ? Curves.linear : Curves.elasticOut,
                        left: currentLeft,
                        top: 4,
                        bottom: 4,
                        width: dropletWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 1.0,
                              colors: [
                                (isDark ? Colors.white : theme.primaryColor)
                                    .withValues(alpha: .25),
                                (isDark ? Colors.white : theme.primaryColor)
                                    .withValues(alpha: .05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        _NavButton(
                          label: 'Search',
                          icon: Assets.icons.searchIcon,
                          isActive: widget.currentIndex == 0,
                        ),
                        _NavButton(
                          label: 'Explore',
                          icon: Assets.icons.explore,
                          isActive: widget.currentIndex == 1,
                        ),
                        _NavButton(
                          label: 'Map',
                          icon: Assets.icons.map,
                          isActive: widget.currentIndex == 2,
                        ),
                        _NavButton(
                          label: 'Wishes',
                          icon: Assets.icons.wishlist,
                          isActive: widget.currentIndex == 3,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final SvgGenImage icon;
  final bool isActive;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isActive
        ? (isDark ? Colors.white : theme.primaryColor)
        : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade400);

    return Expanded(
      child: ColoredBox(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon.svg(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              height: 22,
              width: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: isActive ? FontWeight.w400 : FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final bool isDark;

  const _GlassContainer({
    required this.child,
    required this.height,
    required this.borderRadius,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF171D25) : Colors.white)
                  .withValues(alpha: 0.85),
              borderRadius: borderRadius,
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.05,
                ),
                width: 0.5,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
