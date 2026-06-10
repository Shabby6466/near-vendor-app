import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class AppAlerts {
  AppAlerts._();

  static OverlayEntry? _currentOverlay;

  // ── Public methods ──────────────────────────────────────────────────────────

  // Added optional `isDarkBackground` parameter defaulting to false
  static void showSuccess(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    _showLiquidGlassNotification(
      context: context,
      message: message,
      title: "Success",
      accentColor: const Color(0xFF4CAF50),
      isDarkBackground: isDarkBackground,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    bool isDarkBackground = false,
  }) {
    _showLiquidGlassNotification(
      context: context,
      message: message,
      title: "Error",
      accentColor: const Color(0xFFEF5350),
      isDarkBackground: isDarkBackground,
    );
  }

  // ── Liquid glass notification ────────────────────────────────────────────

  static void _showLiquidGlassNotification({
    required BuildContext context,
    required String title,
    required String message,
    required Color accentColor,
    required bool isDarkBackground,
  }) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    final topPadding = MediaQuery.of(context).padding.top + 8;
    final screenWidth = MediaQuery.of(context).size.width;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) {
        return _LiquidGlassOverlay(
          topPadding: topPadding,
          screenWidth: screenWidth,
          title: title,
          message: message,
          accentColor: accentColor,
          isBackgroundDark: isDarkBackground, // Pass the explicit flag down
          onDismissed: () {
            overlayEntry.remove();
            if (_currentOverlay == overlayEntry) {
              _currentOverlay = null;
            }
          },
        );
      },
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  // ── Confirm dialog ────────────────────────────────────────────────────────

  static Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
    bool isDestructive = true,
  }) {
    return AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: title,
      message: message,
      confirmButtonText: confirmLabel ?? "Confirm",
      onConfirm: onConfirm,
      confirmButtonColor: isDestructive ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
      icon: isDestructive ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
      iconColor: isDestructive ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
    );
  }
}

// ── Liquid Glass Overlay Widget (self-contained) ─────────────────────────

class _LiquidGlassOverlay extends StatefulWidget {
  final double topPadding;
  final double screenWidth;
  final String title;
  final String message;
  final Color accentColor;
  final bool isBackgroundDark; // Use the boolean directly
  final VoidCallback onDismissed;

  const _LiquidGlassOverlay({
    required this.topPadding,
    required this.screenWidth,
    required this.title,
    required this.message,
    required this.accentColor,
    required this.isBackgroundDark,
    required this.onDismissed,
  });

  @override
  State<_LiquidGlassOverlay> createState() => _LiquidGlassOverlayState();
}

class _LiquidGlassOverlayState extends State<_LiquidGlassOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _slide = Tween<Offset>(begin: const Offset(0.0, -1.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (!_controller.isAnimating &&
        _controller.status != AnimationStatus.dismissed) {
      _controller.reverse().then((_) {
        widget.onDismissed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBackgroundDark = widget.isBackgroundDark;

    // Map UI styling values based on the background color state
    final textColor = isBackgroundDark ? Colors.white : Colors.black;
    final messageColor = isBackgroundDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.65);

    final glassColor = isBackgroundDark ? Colors.white : Colors.black;
    final borderGlassColor = isBackgroundDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: SlideTransition(
            position: AlwaysStoppedAnimation(_slide.value),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          SizedBox(
            width: widget.screenWidth,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            top: widget.topPadding,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            glassColor.withValues(
                              alpha: isBackgroundDark ? 0.12 : 0.06,
                            ),
                            glassColor.withValues(
                              alpha: isBackgroundDark ? 0.06 : 0.02,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGlassColor),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 44,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.accentColor == const Color(0xFF4CAF50)
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              color: widget.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    height: 1.2,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.3,
                                    color: messageColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
