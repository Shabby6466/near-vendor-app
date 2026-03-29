import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearvendorapp/models/api_inputs/item_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class AddProductScreen extends StatefulWidget {
  final String shopId;
  final Item? item;

  const AddProductScreen({super.key, required this.shopId, this.item});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;
  late TextEditingController _stockController;
  late TextEditingController _discountController;

  /// New image files picked from gallery (not yet uploaded)
  final List<File> _imageFiles = [];

  /// Existing image URLs from the server (when editing)
  final List<String> _existingImageUrls = [];

  static const int _minImages = 3;
  static const int _maxImages = 5;

  int get _totalImages => _existingImageUrls.length + _imageFiles.length;
  bool get _canAddMore => _totalImages < _maxImages;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(text: widget.item?.description);
    _priceController = TextEditingController(text: widget.item?.price.toString());
    _unitController = TextEditingController(text: widget.item?.unit ?? 'Piece');
    _stockController = TextEditingController(text: widget.item?.stockCount.toString());
    _discountController = TextEditingController(text: widget.item?.discount?.toString() ?? '0');

    if (widget.item != null) {
      _existingImageUrls.addAll(widget.item!.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final remaining = _maxImages - _totalImages;
    if (remaining <= 0) return;

    final pickedFiles = await picker.pickMultiImage(limit: remaining);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (final file in pickedFiles) {
          if (_totalImages < _maxImages) {
            _imageFiles.add(File(file.path));
          }
        }
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_totalImages < _minImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least $_minImages product images',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final cubit = context.read<ItemManagementCubit>();
    if (widget.item == null) {
      final input = CreateItemInput(
        shopId: widget.shopId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        unit: _unitController.text.trim(),
        stockCount: int.tryParse(_stockController.text) ?? 0,
        imageUrls: _existingImageUrls,
        discount: double.tryParse(_discountController.text) ?? 0,
      );
      cubit.createItem(input, imageFiles: _imageFiles);
    } else {
      final input = UpdateItemInput(
        id: widget.item!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        unit: _unitController.text.trim(),
        stockCount: int.tryParse(_stockController.text) ?? 0,
        imageUrls: _existingImageUrls,
        discount: double.tryParse(_discountController.text) ?? 0,
      );
      cubit.updateItem(input, imageFiles: _imageFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.item != null;

    return BlocListener<ItemManagementCubit, ItemManagementState>(
      listener: (context, state) {
        if (state is ItemActionSuccess) {
          Navigator.pop(context);
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Product' : 'Add New Product',
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGalleryPicker(theme),
                const SizedBox(height: 32),
                _buildLabel('Product Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Enter product name'),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),
                _buildLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration('Tell details about your product'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price (PKR)'),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('0.00'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Unit'),
                          TextFormField(
                            controller: _unitController,
                            decoration: _inputDecoration('e.g. Piece, Kg'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Stock Count'),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Discount (%)'),
                          TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('0'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                BlocBuilder<ItemManagementCubit, ItemManagementState>(
                  builder: (context, state) {
                    final isLoading = state is ItemActionLoading;
                    final message = state is ItemActionLoading ? state.message : null;
                    return Column(
                      children: [
                        if (isLoading && message != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              message,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        AppElevatedButton(
                          text: isLoading
                              ? 'Saving...'
                              : (isEdit ? 'Update Details' : 'Publish Product'),
                          onPressed: isLoading ? null : _submit,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Premium Multi-Image Gallery Picker ──────────────────────────────

  Widget _buildImageGalleryPicker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with counter
        Row(
          children: [
            Text(
              'Product Photos',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _totalImages >= _minImages
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalImages / $_maxImages',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _totalImages >= _minImages ? Colors.green : theme.primaryColor,
                ),
              ),
            ),
            const Spacer(),
            if (_totalImages < _minImages)
              Text(
                'Min $_minImages required',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade400,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Image Grid
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _totalImages + (_canAddMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              // Existing URLs come first
              if (index < _existingImageUrls.length) {
                return _buildNetworkImageTile(
                  theme, isDark, _existingImageUrls[index], index,
                );
              }

              // Then new local files
              final newFileIndex = index - _existingImageUrls.length;
              if (newFileIndex < _imageFiles.length) {
                return _buildFileImageTile(
                  theme, isDark, _imageFiles[newFileIndex], newFileIndex,
                );
              }

              // Last slot = add button
              return _buildAddImageTile(theme, isDark);
            },
          ),
        ),

        const SizedBox(height: 8),
        // Helper text
        Text(
          'Tap + to add photos. Hold and drag to reorder. Tap × to remove.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImageTile(ThemeData theme, bool isDark, String url, int index) {
    return _buildImageTileWrapper(
      theme: theme,
      isDark: isDark,
      onRemove: () => _removeExistingImage(index),
      badgeIndex: index + 1,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Icon(
          Icons.broken_image_rounded,
          color: theme.iconTheme.color?.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildFileImageTile(ThemeData theme, bool isDark, File file, int index) {
    return _buildImageTileWrapper(
      theme: theme,
      isDark: isDark,
      onRemove: () => _removeNewImage(index),
      badgeIndex: _existingImageUrls.length + index + 1,
      child: Image.file(file, fit: BoxFit.cover),
    );
  }

  Widget _buildImageTileWrapper({
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onRemove,
    required int badgeIndex,
    required Widget child,
  }) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: child,
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),

          // Index badge
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$badgeIndex',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageTile(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 120,
        height: 140,
        decoration: BoxDecoration(
          color: isDark
              ? theme.primaryColor.withValues(alpha: 0.08)
              : theme.primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: 24,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: theme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Helpers ──────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
