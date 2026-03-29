import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_map_results_screen.dart';
import 'package:nearvendorapp/views/screens/search/widgets/scanning_area.dart';
import 'package:nearvendorapp/views/screens/search/widgets/visual_search_result_sheet.dart';
import 'package:nearvendorapp/views/screens/search/widgets/no_result_sheet.dart';

class VisualSearchScreen extends StatefulWidget {
  final File? initialImage;
  const VisualSearchScreen({super.key, this.initialImage});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scannerController);

    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VisualSearchCubit>().searchByImage(_selectedImage!);
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        if (mounted) {
          context.read<VisualSearchCubit>().searchByImage(_selectedImage!);
        }
      }
    } catch (e) {
      debugPrint("Pick image error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background: Image or Placeholder
          Positioned.fill(
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : _buildEmptyState(),
          ),

          // Dim overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // Search Results Bottom Sheet Trigger
          BlocListener<VisualSearchCubit, VisualSearchState>(
            listener: (context, state) {
              if (state is VisualSearchSuccess) {
                if (state.results.isEmpty) {
                  _showNoResultBottomSheet(context);
                } else {
                  _showScanResultBottomSheet(context, state.results);
                }
              } else if (state is VisualSearchFailure) {
                _showNoResultBottomSheet(context, message: state.message);
              }
            },
            child: const SizedBox.shrink(),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const Spacer(),
                if (_selectedImage != null)
                  ScanningArea(scannerAnimation: _scannerAnimation),
                const Spacer(),
                if (_selectedImage == null) _buildInstructionText(),
                const SizedBox(height: 48),
                BlocBuilder<VisualSearchCubit, VisualSearchState>(
                  builder: (context, state) {
                    if (state is VisualSearchLoading) {
                      return _buildLoadingState();
                    }
                    return _buildBottomActions();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 80,
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
          const Text(
            'VISUAL SEARCH',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 2,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 48), // Balanced spacer
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Column(
      children: [
        const Text(
          'Capture or Select an Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تصویر لیں یا گیلری سے منتخب کریں',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            "Analyzing Product...",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionIconButton(
            Icons.collections_outlined,
            "GALLERY",
            () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          const SizedBox(width: 60), // Balanced spacer
        ],
      ),
    );
  }

  Widget _buildActionIconButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showScanResultBottomSheet(BuildContext context, List<Item> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (innerContext) => BlocProvider.value(
        value: context.read<VisualSearchCubit>(),
        child: VisualSearchResultSheet(
          items: items,
          onAccept: () {
            Navigator.pop(innerContext);
            AppNavigator.push(
              context,
              VisualSearchMapResultsScreen(results: items),
            );
          },
          onTryAgain: () {
            Navigator.pop(innerContext);
            setState(() {
              _selectedImage = null;
            });
            context.read<VisualSearchCubit>().reset();
          },
        ),
      ),
    );
  }

  void _showNoResultBottomSheet(BuildContext context, {String? message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (innerContext) => BlocProvider.value(
        value: context.read<VisualSearchCubit>(),
        child: NoResultSheet(
          message: message,
          onIncreaseRadius: () {
            Navigator.pop(innerContext);
          },
          onDismiss: () {
            Navigator.pop(innerContext);
            setState(() {
              _selectedImage = null;
            });
            context.read<VisualSearchCubit>().reset();
          },
        ),
      ),
    );
  }
}
