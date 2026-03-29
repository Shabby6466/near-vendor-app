import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/api_inputs/item_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';

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
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(
      text: widget.item?.description,
    );
    _priceController = TextEditingController(
      text: widget.item?.price.toString(),
    );
    _unitController = TextEditingController(text: widget.item?.unit ?? 'Piece');
    _stockController = TextEditingController(
      text: widget.item?.stockCount.toString(),
    );
    _discountController = TextEditingController(
      text: widget.item?.discount?.toString() ?? '0',
    );
    _existingImageUrl = widget.item?.imageUrl;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ItemManagementCubit>();
    if (widget.item == null) {
      final input = CreateItemInput(
        shopId: widget.shopId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        unit: _unitController.text.trim(),
        stockCount: int.tryParse(_stockController.text) ?? 0,
        imageUrl: null,
        discount: double.tryParse(_discountController.text) ?? 0,
      );
      cubit.createItem(input, imageFile: _imageFile);
    } else {
      final input = UpdateItemInput(
        id: widget.item!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        unit: _unitController.text.trim(),
        stockCount: int.tryParse(_stockController.text) ?? 0,
        imageUrl: _existingImageUrl,
        discount: double.tryParse(_discountController.text) ?? 0,
      );
      cubit.updateItem(input, imageFile: _imageFile);
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
          title: Text(isEdit ? 'Edit Product' : 'Add New Product'),
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
                _buildImagePicker(theme),
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
                  decoration: _inputDecoration(
                    'Tell details about your product',
                  ),
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
                    return AppElevatedButton(
                      text: isLoading
                          ? 'Saving...'
                          : (isEdit ? 'Update Details' : 'Publish Product'),
                      onPressed: isLoading ? null : _submit,
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

  Widget _buildImagePicker(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : (_existingImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CircularCachedNetworkImage(
                          imageUrl: _existingImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 40,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Product Photo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )),
        ),
      ),
    );
  }
}
