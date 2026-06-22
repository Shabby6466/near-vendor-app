import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class MultiImagePicker extends StatefulWidget {
  final List<File> initialImages;
  final int maxImages;
  final ValueChanged<List<File>>? onImagesChanged;

  const MultiImagePicker({
    super.key,
    this.initialImages = const [],
    this.maxImages = 5,
    this.onImagesChanged,
  });

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final ImagePicker _picker = ImagePicker();
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= widget.maxImages) return;
    final image = await _picker.pickImage(source: source);
    if (image == null || !mounted) return;
    setState(() => _images.add(File(image.path)));
    widget.onImagesChanged?.call(_images);
    AppNavigator.pop(context);
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
    widget.onImagesChanged?.call(_images);
  }

  void _showImageSourceSheet() {
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Camera'),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: const Text('Gallery'),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  void _previewImage(int index) {
    AppNavigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImageFullScreenViewer(
          images: _images,
          initialIndex: index,
          onRemove: (i) {
            setState(() => _images.removeAt(i));
            widget.onImagesChanged?.call(_images);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = _images.length < widget.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_images.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _images.length; i++)
                _buildImageTile(i, theme),
              if (canAddMore) _buildAddTile(theme),
            ],
          )
        else
          _buildAddTile(theme, isLarge: true),
      ],
    );
  }

  Widget _buildImageTile(int index, ThemeData theme) {
    return GestureDetector(
      onTap: () => _previewImage(index),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _images[index],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTile(ThemeData theme, {bool isLarge = false}) {
    final size = isLarge ? 90.0 : 90.0;
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: theme.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              '${_images.length}/${widget.maxImages}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFullScreenViewer extends StatelessWidget {
  final List<File> images;
  final int initialIndex;
  final ValueChanged<int> onRemove;

  const _ImageFullScreenViewer({
    required this.images,
    required this.initialIndex,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => onRemove(pageController.page?.round() ?? 0),
          ),
        ],
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: images.length,
        itemBuilder: (context, index) =>
            InteractiveViewer(child: Center(child: Image.file(images[index]))),
      ),
    );
  }
}
