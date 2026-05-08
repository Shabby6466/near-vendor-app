import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

class SearchBarField extends StatefulWidget {
  final FocusNode? focusNode;
  const SearchBarField({super.key, this.focusNode});

  @override
  State<SearchBarField> createState() => SearchBarFieldState();
}

class SearchBarFieldState extends State<SearchBarField> {
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onSearch(String query) {
    HapticFeedback.mediumImpact();
    final sessionState = context.read<SessionCubit>().state;
    final lat = sessionState.latitude ?? 0.0;
    final lon = sessionState.longitude ?? 0.0;

    context.read<SearchCubit>().searchItems(lat: lat, lon: lon, query: query);
  }

  void showVisualSearchDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1C1C23).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorName.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Assets.icons.camera.svg(
                    colorFilter: const ColorFilter.mode(
                      ColorName.primary,
                      BlendMode.srcIn,
                    ),
                    width: 32,
                    height: 32,
                  ),
                ).animate().scale(
                  delay: 100.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),
                const SizedBox(height: 20),
                Text(
                  'Visual Search',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search for items instantly using your\ncamera or photo gallery.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        context,
                        icon: CupertinoIcons.camera,
                        label: 'Camera',
                        onTap: () =>
                            _navigateToVisualSearch(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDialogButton(
                        context,
                        icon: CupertinoIcons.photo,
                        label: 'Gallery',
                        onTap: () =>
                            _navigateToVisualSearch(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
      ),
    );
  }

  Widget _buildDialogButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorName.primary, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToVisualSearch(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        AppNavigator.push(
          context,
          BlocProvider(
            create: (context) => VisualSearchCubit(),
            child: VisualSearchScreen(initialImage: File(pickedFile.path)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: _controller,
      focusNode: _focusNode,
      hintText: 'Search high-value items...',
      showVisualSearch: true,
      onVisualSearchTap: showVisualSearchDialog,
      onSearch: _onSearch,
      onChanged: (value) {
        setState(() {});
        if (value.isEmpty) {
          context.read<SearchCubit>().clearSearch();
        }
      },
      onClear: () {
        context.read<SearchCubit>().clearSearch();
      },
    );
  }
}
