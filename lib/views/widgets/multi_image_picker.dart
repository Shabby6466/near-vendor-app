import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class MultiImagePicker extends StatefulWidget {
  final List<File> initialImages;
  final List<String> initialImageUrls;
  final int maxImages;
  final ValueChanged<List<File>>? onImagesChanged;
  final ValueChanged<List<String>>? onImageUrlsChanged;

  const MultiImagePicker({
    super.key,
    this.initialImages = const [],
    this.initialImageUrls = const [],
    this.maxImages = 5,
    this.onImagesChanged,
    this.onImageUrlsChanged,
  });

  /// Public helper so external widgets (e.g. CommentInput) can show the same
  /// camera / gallery picker sheet and receive the chosen [File] via [onPicked].
  static void showPickerSheet({
    required BuildContext context,
    required ValueChanged<File> onPicked,
  }) {
    final picker = ImagePicker();
    AppBottomSheet.showBottomSheet(
      context: context,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () async {
                AppNavigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) onPicked(File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Gallery'),
              onTap: () async {
                AppNavigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) onPicked(File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  late List<File> _images;
  late List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
    _imageUrls = List.from(widget.initialImageUrls);
  }

  void _removeNetworkImage(int index) {
    setState(() => _imageUrls.removeAt(index));
    widget.onImageUrlsChanged?.call(_imageUrls);
  }

  void _removeLocalImage(int index) {
    setState(() => _images.removeAt(index));
    widget.onImagesChanged?.call(_images);
  }

  void _showImageSourceSheet() {
    MultiImagePicker.showPickerSheet(
      context: context,
      onPicked: (file) {
        if (!mounted) return;
        final totalCount = _imageUrls.length + _images.length;
        if (totalCount >= widget.maxImages) return;
        setState(() => _images.add(file));
        widget.onImagesChanged?.call(_images);
      },
    );
  }

  void _previewImage(int index) {
    final allItems = [..._imageUrls, ..._images];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImageFullScreenViewer(
          items: allItems,
          initialIndex: index,
          onRemove: (i) {
            if (i < _imageUrls.length) {
              setState(() => _imageUrls.removeAt(i));
              widget.onImageUrlsChanged?.call(_imageUrls);
            } else {
              final localIndex = i - _imageUrls.length;
              setState(() => _images.removeAt(localIndex));
              widget.onImagesChanged?.call(_images);
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCount = _imageUrls.length + _images.length;
    final canAddMore = totalCount < widget.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalCount > 0)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (int i = 0; i < _imageUrls.length; i++)
                _buildNetworkImageTile(i, theme),
              for (int i = 0; i < _images.length; i++)
                _buildLocalImageTile(i, theme),
              if (canAddMore) _buildAddTile(theme),
            ],
          )
        else
          _buildAddTile(theme, isLarge: true),
      ],
    );
  }

  Widget _buildNetworkImageTile(int index, ThemeData theme) {
    return GestureDetector(
      onTap: () => _previewImage(index),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _imageUrls[index],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 90,
                height: 90,
                color: theme.cardColor,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingAnimation(size: 20),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 90,
                height: 90,
                color: theme.cardColor,
                child: const Icon(Icons.error_outline),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeNetworkImage(index),
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

  Widget _buildLocalImageTile(int index, ThemeData theme) {
    final previewIndex = _imageUrls.length + index;
    return GestureDetector(
      onTap: () => _previewImage(previewIndex),
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
              onTap: () => _removeLocalImage(index),
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
    const size = 90.0;
    final totalCount = _imageUrls.length + _images.length;
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
              '$totalCount/${widget.maxImages}',
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
  final List<dynamic> items;
  final int initialIndex;
  final ValueChanged<int> onRemove;

  const _ImageFullScreenViewer({
    required this.items,
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
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          Widget imageWidget;
          if (item is String) {
            imageWidget = CachedNetworkImage(
              imageUrl: item,
              placeholder: (context, url) =>
                  const Center(child: LoadingAnimation(color: Colors.white)),
              errorWidget: (context, url, error) => const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 40,
              ),
            );
          } else if (item is File) {
            imageWidget = Image.file(item);
          } else {
            imageWidget = const SizedBox.shrink();
          }
          return InteractiveViewer(child: Center(child: imageWidget));
        },
      ),
    );
  }
}
