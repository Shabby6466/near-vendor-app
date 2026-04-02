import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onVisualSearchTap;
  final bool showVisualSearch;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsets? padding;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.onVisualSearchTap,
    this.showVisualSearch = false,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.padding,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onSearch(String query) {
    HapticFeedback.mediumImpact();
    widget.onSearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedScale(
        duration: 250.ms,
        scale: _isFocused ? 1.02 : 1.0,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: 250.ms,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? theme.primaryColor.withValues(alpha: 0.15)
                    : (isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.05)),
                blurRadius: _isFocused ? 20 : 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_rounded,
                color: _isFocused || _controller.text.isNotEmpty
                    ? theme.colorScheme.onSurface
                    : theme.iconTheme.color?.withValues(alpha: 0.3),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  onSubmitted: (value) {
                    _onSearch(value);
                  },
                  onChanged: (value) {
                    setState(() {});
                    widget.onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    filled: false,
                    hoverColor: Colors.transparent,
                    hintText: widget.hintText,
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodySmall!.color!.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.iconTheme.color?.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                    widget.onClear?.call();
                    setState(() {});
                  },
                ),
              if (widget.showVisualSearch) ...[
                Container(
                  width: 1,
                  height: 20,
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onVisualSearchTap?.call();
                  },
                  child:
                      SvgPicture.asset(
                            'assets/icons/camera.svg',
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFFF4D00),
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 1.seconds,
                            curve: Curves.easeInOut,
                          ),
                ),
                const SizedBox(width: 16),
              ] else
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
