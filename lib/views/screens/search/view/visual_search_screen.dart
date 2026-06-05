import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/view/visual_search_map_results_screen.dart';
import 'package:nearvendorapp/views/screens/search/widgets/no_result_sheet.dart';
import 'package:nearvendorapp/views/screens/search/widgets/scanning_area.dart';
import 'package:nearvendorapp/views/screens/search/widgets/visual_search_result_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_loading_indicator.dart';

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
  double _currentRadiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _currentRadiusKm = AppData().discoveryRadius ?? 10.0;
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scannerController);

    if (widget.initialImage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cropAndSearch(widget.initialImage!.path);
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

      if (pickedFile == null) return;
      await _cropAndSearch(pickedFile.path);
    } catch (e) {
      debugPrint("Pick image error: $e");
    }
  }

  Future<void> _cropAndSearch(String sourcePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Frame the product',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Frame the product',
            doneButtonTitle: 'Search',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.original,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
        if (mounted) {
          context.read<VisualSearchCubit>().searchByImage(_selectedImage!);
        }
      } else {
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      debugPrint("Crop image error: $e");
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
                    fit: BoxFit.contain,
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
                  _showNoResultBottomSheet(
                    context,
                    radiusUsed: state.radiusUsed,
                    hasMoreBeyondRadius: state.hasMoreBeyondRadius,
                  );
                } else {
                  _showScanResultBottomSheet(context, state.results);
                }
              } else if (state is VisualSearchFailure) {
                _showNoResultBottomSheet(
                  context,
                  message: state.message,
                  radiusUsed: state.radiusUsed,
                  hasMoreBeyondRadius: state.hasMoreBeyondRadius,
                );
              }
            },
            child: const SizedBox.shrink(),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                _buildRadiusSliderCard(),
                const Spacer(),
                if (_selectedImage != null)
                  ScanningArea(scannerAnimation: _scannerAnimation),
                const Spacer(),
                if (_selectedImage == null) _buildInstructionText(),
                const SizedBox(height: 48),
                BlocBuilder<VisualSearchCubit, VisualSearchState>(
                  builder: (context, state) {
                    if (state is VisualSearchLoading) {
                      return const AppLoadingIndicator();
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
        child: Assets.icons.camera.svg(
          height: 80,
          width: 80,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.1),
            BlendMode.srcIn,
          ),
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
            ),
        ),
        const SizedBox(height: 8),
        Text(
          'تصویر لیں یا گیلری سے منتخب کریں',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            ),
        ),
      ],
    );
  }

  // Widget _buildLoadingState() {
  //   return Center(
  //     child: Column(
  //       children: [
  //         const LoadingAnimation(color: Colors.white, size: 28),
  //         const SizedBox(height: 16),
  //         const Text(
  //           "Analyzing Product...",
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //             //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionIconButton(
            const Icon(
              Icons.collections_outlined,
              color: Colors.white,
              size: 28,
            ),
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
                child: Center(
                  child: Assets.icons.camera.svg(
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                    width: 32,
                    height: 32,
                  ),
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

  Widget _buildActionIconButton(Widget icon, String label, VoidCallback onTap) {
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
            child: icon,
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

  void _showScanResultBottomSheet(BuildContext context, List<Product> items) {
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

  void _showNoResultBottomSheet(
    BuildContext context, {
    String? message,
    double? radiusUsed,
    bool hasMoreBeyondRadius = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (innerContext) => BlocProvider.value(
        value: context.read<VisualSearchCubit>(),
        child: NoResultSheet(
          message: message,
          radiusUsed: radiusUsed,
          hasMoreBeyondRadius: hasMoreBeyondRadius,
          onIncreaseRadius: () {
            Navigator.pop(innerContext);
            if (_selectedImage != null && radiusUsed != null) {
              final double expandedRadiusMeters = (radiusUsed * 3.0).clamp(1000.0, 50000.0);
              context.read<VisualSearchCubit>().searchByImage(
                    _selectedImage!,
                    customRadiusMeters: expandedRadiusMeters,
                  );
            }
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

  Widget _buildRadiusSliderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discovery Radius',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_currentRadiusKm.toStringAsFixed(0)} KM',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: _currentRadiusKm,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    onChanged: (val) {
                      setState(() {
                        _currentRadiusKm = val;
                      });
                    },
                    onChangeEnd: (val) async {
                      await AppData().setDiscoveryRadius(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
