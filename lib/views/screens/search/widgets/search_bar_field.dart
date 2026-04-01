import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/utils/app_bottom_sheet.dart';

import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchBarField extends StatefulWidget {
  const SearchBarField({super.key});

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    HapticFeedback.mediumImpact();
    final sessionState = context.read<SessionCubit>().state;
    final lat = sessionState.latitude ?? 0.0;
    final lon = sessionState.longitude ?? 0.0;

    context.read<SearchCubit>().searchItems(lat: lat, lon: lon, query: query);
  }

  void _showImageSourceSelector() {
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Visual Search',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for items using your camera or an image from your gallery',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceButton(
                iconWidget: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn),
                  width: 32,
                  height: 32,
                ),
                label: 'Camera',
                onTap: () => _navigateToVisualSearch(ImageSource.camera),
              ),
              _buildSourceButton(
                iconWidget: Icon(Icons.photo_library_rounded,
                    color: Theme.of(context).primaryColor, size: 32),
                label: 'Gallery',
                onTap: () => _navigateToVisualSearch(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: iconWidget,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedScale(
        duration: 250.ms,
        scale: _isFocused ? 1.02 : 1.0,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: 250.ms,
          height: 56,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _isFocused 
                  ? theme.primaryColor.withValues(alpha: 0.15) 
                  : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05)),
                blurRadius: _isFocused ? 20 : 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: _isFocused
                ? theme.primaryColor.withValues(alpha: 0.5)
                : (_controller.text.isNotEmpty 
                  ? theme.primaryColor.withValues(alpha: 0.4)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200)),
              width: 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_rounded,
                color: _isFocused || _controller.text.isNotEmpty 
                  ? theme.primaryColor 
                  : theme.iconTheme.color?.withValues(alpha: 0.3),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: false,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  onSubmitted: _onSearch,
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty) {
                      context.read<SearchCubit>().clearSearch();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search high-value items...',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.iconTheme.color?.withValues(alpha: 0.4), size: 18),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                    context.read<SearchCubit>().clearSearch();
                    setState(() {});
                  },
                ),
              Container(
                width: 1,
                height: 20,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showImageSourceSelector();
                },
                child: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  colorFilter: const ColorFilter.mode(
                      Color(0xFFFF4D00), BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper for the brand color if not available, otherwise use theme.primary
const orangeBrandColor = Color(0xFFF3B700);
