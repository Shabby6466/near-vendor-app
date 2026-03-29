import 'package:flutter/material.dart';

/// A widget that only builds its child when it becomes visible for the first time.
/// Useful for [IndexedStack] or [PageView] to defer cubit initialization until needed.
class LazyLoadWrapper extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const LazyLoadWrapper({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized && widget.isVisible) {
      _initialized = true;
    }

    if (_initialized) {
      return widget.child;
    } else {
      return const SizedBox.shrink();
    }
  }
}
