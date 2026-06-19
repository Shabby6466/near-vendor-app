import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/cubit/product_detail_cubit.dart';
import 'package:nearvendorapp/views/screens/product_detail_screen/view/product_detail_screen.dart';
import 'package:nearvendorapp/views/screens/search/visual_search/cubit/visual_search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/visual_search/widgets/camera_preview_widget.dart';
import 'package:nearvendorapp/views/screens/search/visual_search/widgets/crop_overlay_widget.dart';
import 'package:nearvendorapp/views/screens/search/visual_search/widgets/visual_search_result_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class VisualSearchScreen extends StatefulWidget {
  const VisualSearchScreen({super.key});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  // Mode
  bool _isCameraMode = true;

  // Camera
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isCameraInitializing = true;

  // Image state
  File? _selectedImage;
  File? _currentCroppedFile;
  double _currentRadiusKm = 10.0;

  // Display size (set via LayoutBuilder in preview mode)
  Size? _imageDisplaySize;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentRadiusKm = AppData().discoveryRadius ?? 10.0;
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    setState(() => _isCameraInitializing = true);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _isCameraInitializing = false);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _isCameraInitializing = false;
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) setState(() => _isCameraInitializing = false);
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile photo = await _cameraController!.takePicture();
      final file = File(photo.path);
      await _cameraController?.dispose();
      _cameraController = null;
      if (!mounted) return;
      setState(() {
        _isCameraMode = false;
        _selectedImage = file;
        _currentCroppedFile = file;
      });
      context.read<VisualSearchCubit>().searchByImage(
        file,
        customRadiusMeters: _currentRadiusKm * 1000,
      );
    } catch (e) {
      debugPrint('Take picture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile == null) return;
      final file = File(pickedFile.path);
      if (!mounted) return;
      setState(() {
        _isCameraMode = false;
        _selectedImage = file;
        _currentCroppedFile = file;
      });
      context.read<VisualSearchCubit>().searchByImage(
        file,
        customRadiusMeters: _currentRadiusKm * 1000,
      );
    } catch (e) {
      debugPrint('Pick gallery error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    await _cameraController!.setFlashMode(newMode);
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _goBackToCamera() {
    setState(() {
      _isCameraMode = true;
      _selectedImage = null;
      _currentCroppedFile = null;
    });
    context.read<VisualSearchCubit>().reset();
    _initCamera();
  }

  Future<void> _applyCrop(Rect region) async {
    if (_selectedImage == null) return;
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return;

      final displayedW = _imageDisplaySize?.width ?? original.width.toDouble();
      final displayedH =
          _imageDisplaySize?.height ?? original.height.toDouble();
      final scaleX = original.width / displayedW;
      final scaleY = original.height / displayedH;

      final cropped = img.copyCrop(
        original,
        x: (region.left * scaleX).round(),
        y: (region.top * scaleY).round(),
        width: (region.width * scaleX).round(),
        height: (region.height * scaleY).round(),
      );

      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(cropped));
      _currentCroppedFile = tempFile;
      if (mounted) {
        context.read<VisualSearchCubit>().searchByImage(
          tempFile,
          customRadiusMeters: _currentRadiusKm * 1000,
        );
      }
    } catch (e) {
      debugPrint('Crop error: $e');
    }
  }

  void _showShopSelectorSheet(
    BuildContext context,
    String productName,
    List<Product> options,
  ) {
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select shop for $productName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...options.map((item) {
            final distanceText = item.distanceM != null
                ? '${(item.distanceM! / 1000).toStringAsFixed(1)} km away'
                : 'Nearby';

            Widget leadingWidget;
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
              leadingWidget = ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            } else {
              leadingWidget = Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.blue,
                ),
              );
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ),
              leading: leadingWidget,
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Rs. ${item.price.toStringAsFixed(0)} • $distanceText',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pop();
                AppNavigator.push(
                  context,
                  BlocProvider(
                    create: (_) => ProductDetailCubit(),
                    child: ProductDetailScreen(product: item),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraMode) _buildCameraMode() else _buildPreviewMode(),
        ],
      ),
    );
  }

  Widget _buildCameraMode() {
    return Stack(
      children: [
        if (_isCameraInitializing)
          const Center(child: LoadingAnimation(size: 32))
        else if (_cameraController != null &&
            _cameraController!.value.isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize?.height ?? 1,
                height: _cameraController!.value.previewSize?.width ?? 1,
                child: CameraPreview(_cameraController!),
              ),
            ),
          )
        else
          _buildCameraFallback(),

        CameraControlsOverlay(
          onShutter: _takePicture,
          onGallery: _pickFromGallery,
          onClose: () => AppNavigator.pop(context),
          isFlashOn: _isFlashOn,
          onToggleFlash: _toggleFlash,
          bottomContent: _buildRadiusSlider(compact: true),
        ),
      ],
    );
  }

  Widget _buildCameraFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.camera.svg(
              height: 80,
              width: 80,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.1),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera unavailable',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _initCamera,
              child: const Text(
                'Try again',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewMode() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // 1. Image & Crop Overlay (Top 60%)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ColoredBox(
            color: Colors.black,
            child: SafeArea(
              bottom: false, // Let it extend behind the bottom sheet
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  _imageDisplaySize = size;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                        width: size.width,
                        height: size.height,
                      ),
                      SizedBox(
                        width: size.width,
                        height: size.height,
                        child: CropOverlayWidget(
                          imageDisplaySize: size,
                          onCropComplete: _applyCrop,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // 2. Bottom Sheet (Persistent)
        Positioned.fill(
          child: VisualSearchResultSheet(
            radiusKm: _currentRadiusKm,
            onRadiusChanged: (val) {
              setState(() => _currentRadiusKm = val);
            },
            onRadiusChangeEnd: (val) async {
              await AppData().setDiscoveryRadius(val);
              if (_currentCroppedFile != null && mounted) {
                context.read<VisualSearchCubit>().searchByImage(
                  _currentCroppedFile!,
                  customRadiusMeters: val * 1000,
                );
              }
            },
            onGroupTap: (groupItems) {
              if (groupItems.length > 1) {
                _showShopSelectorSheet(
                  context,
                  groupItems.first.name,
                  groupItems,
                );
              } else if (groupItems.isNotEmpty) {
                AppNavigator.push(
                  context,
                  BlocProvider(
                    create: (_) => ProductDetailCubit(),
                    child: ProductDetailScreen(product: groupItems.first),
                  ),
                );
              }
            },
            onTryAgain: _goBackToCamera,
          ),
        ),

        // 3. Top Back Button (Always on top)
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: IconButton(
            onPressed: _goBackToCamera,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusSlider({bool compact = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discovery Radius',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 12 : 15,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_currentRadiusKm.toStringAsFixed(0)} KM',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: compact ? 12 : 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _currentRadiusKm,
              min: 1.0,
              max: 100.0,
              divisions: 49,
              onChanged: (val) {
                setState(() => _currentRadiusKm = val);
              },
              onChangeEnd: (val) async {
                await AppData().setDiscoveryRadius(val);
                // In camera view, it just updates the preferred radius for next search
              },
            ),
          ),
        ],
      ),
    );
  }
}
