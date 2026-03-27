import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';

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

  void _handleInteraction(Offset localPosition, double totalWidth, {required bool isDragging}) {
    final itemWidth = totalWidth / 4;
    final newDragX = localPosition.dx.clamp(8.0, totalWidth - 8.0);
    final currentVelocity = isDragging ? (newDragX - _lastDragX).abs() : 0.0;

    setState(() {
      _isDragging = isDragging;
      _dragX = newDragX;
      _velocity = isDragging ? (_velocity * 0.8 + currentVelocity * 0.2) : 0.0;
      _lastDragX = newDragX;
    });

    int index = (newDragX / itemWidth).floor().clamp(0, 3);
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

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final bool isVendor = state.isVendor && state.vendorStatus == 'APPROVED';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: AnimatedScale(
              scale: _isDragging ? 1.01 : 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              child: Row(
                children: [
                  Expanded(
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
                          final velocityStretch = (_velocity * 0.8).clamp(
                            0.0,
                            30.0,
                          );
                          final dropletWidth =
                              baseDropletWidth + velocityStretch;

                          final targetLeft =
                              (widget.currentIndex * itemWidth) +
                              8 -
                              (velocityStretch / 2);
                          final currentLeft = _isDragging
                              ? (_dragX - (dropletWidth / 2)).clamp(
                                  8.0,
                                  totalWidth - dropletWidth - 8.0,
                                )
                              : targetLeft;

                          return GestureDetector(
                            onHorizontalDragStart: (_) =>
                                setState(() => _isDragging = true),
                            onHorizontalDragUpdate: (details) =>
                                _handleInteraction(
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
                                        : const Duration(milliseconds: 600),
                                    curve: _isDragging
                                        ? Curves.linear
                                        : Curves.elasticOut,
                                    left: currentLeft,
                                    top: 5,
                                    bottom: 5,
                                    width: dropletWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.4, -0.4),
                                          radius: 1.0,
                                          colors: [
                                            (isDark
                                                    ? Colors.white
                                                    : theme.primaryColor)
                                                .withValues(alpha: .25),
                                            (isDark
                                                    ? Colors.white
                                                    : theme.primaryColor)
                                                .withValues(alpha: .05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color:
                                              (isDark
                                                      ? Colors.white
                                                      : theme.primaryColor)
                                                  .withValues(alpha: .2),
                                          width: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha:
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Stack(
                                        children: [_DropletShine()],
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    _NavButton(
                                      label: 'Search',
                                      icon: Assets.icons.searchIcon.path,
                                      isActive: widget.currentIndex == 0,
                                    ),
                                    _NavButton(
                                      label: 'Explore',
                                      icon: Assets.icons.homeIcon.path,
                                      isActive: widget.currentIndex == 1,
                                    ),
                                    _NavButton(
                                      label: 'Map',
                                      icon: Assets.icons.mapIcon.path,
                                      isActive: widget.currentIndex == 2,
                                    ),
                                    _NavButton(
                                      label: 'Chat',
                                      icon: Icons.chat_bubble_outline,
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
                  if (isVendor) ...[
                    const SizedBox(width: 12),
                    _VendorConsoleButton(
                      isActive: widget.currentIndex == 4,
                      onTap: () => _onItemTapped(4),
                      height: barHeight,
                      isDark: isDark,
                      primaryColor: theme.primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final dynamic icon;
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (icon is IconData) {
      return Icon(icon as IconData, color: color, size: 22);
    }
    if (icon is String && (icon as String).contains('.svg')) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: icon == Assets.icons.homeIcon.path
            ? Assets.icons.homeIcon.svg(height: 22, width: 22)
            : icon == Assets.icons.mapIcon.path
            ? Assets.icons.mapIcon.svg(height: 22, width: 22)
            : icon == Assets.icons.searchIcon.path
            ? Assets.icons.searchIcon.svg(height: 22, width: 22)
            : Assets.icons.profileIcon.svg(height: 22, width: 22),
      );
    }
    return const SizedBox();
  }
}

class _VendorConsoleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final double height;
  final bool isDark;
  final Color primaryColor;

  const _VendorConsoleButton({
    required this.isActive,
    required this.onTap,
    required this.height,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? Colors.white : primaryColor;
    return _GlassContainer(
      height: height,
      width: height,
      borderRadius: BorderRadius.circular(height / 2),
      isDark: isDark,
      border: isActive
          ? Border.all(color: activeColor.withValues(alpha: 0.5), width: 2)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: activeColor.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(
              isActive ? Icons.store : Icons.store_outlined,
              color: isActive
                  ? activeColor
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.grey.shade400),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final bool isDark;

  const _GlassContainer({
    required this.child,
    required this.height,
    this.width,
    required this.borderRadius,
    this.border,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF171D25) : Colors.white)
                  .withValues(alpha: 0.85),
              borderRadius: borderRadius,
              border:
                  border ??
                  Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha:
                      0.05,
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

class _DropletShine extends StatelessWidget {
  const _DropletShine();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      left: 10,
      child: Container(
        width: 12,
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.2),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
