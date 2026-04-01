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
import 'package:nearvendorapp/views/widgets/app_search_bar.dart';

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
    return AppSearchBar(
      controller: _controller,
      focusNode: _focusNode,
      hintText: 'Search high-value items...',
      showVisualSearch: true,
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

// Helper for the brand color if not available, otherwise use theme.primary
const orangeBrandColor = Color(0xFFF3B700);
