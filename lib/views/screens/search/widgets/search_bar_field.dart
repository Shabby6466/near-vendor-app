import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/utils/app_bottom_sheet.dart';

class SearchBarField extends StatefulWidget {
  const SearchBarField({super.key});

  @override
  State<SearchBarField> createState() => _SearchBarFieldState();
}

class _SearchBarFieldState extends State<SearchBarField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
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
          const Text(
            'Visual Search',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search for items using your camera or an image from your gallery',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () => _navigateToVisualSearch(ImageSource.camera),
              ),
              _buildSourceButton(
                icon: Icons.photo_library_rounded,
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
    required IconData icon,
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
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1))
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          autofocus: false,
          style: const TextStyle(fontFamily: 'Poppins'),
          onSubmitted: _onSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              context.read<SearchCubit>().clearSearch();
            }
          },
          decoration: InputDecoration(
            hintText: 'Search Item',
            hintStyle: TextStyle(
              color: theme.textTheme.bodySmall!.color!.withValues(alpha: 0.4),
            ),
            prefixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: theme.iconTheme.color?.withValues(alpha: 0.5),
              ),
              onPressed: () => _onSearch(_controller.text),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _showImageSourceSelector,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: theme.iconTheme.color?.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.mic_none,
                  color: theme.iconTheme.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 16),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
