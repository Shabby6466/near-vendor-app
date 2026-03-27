import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/item_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/item_management/cubit/item_management_cubit.dart';

class ItemFormBottomSheet extends StatefulWidget {
  final String shopId;
  final Item? item;

  const ItemFormBottomSheet({super.key, required this.shopId, this.item});

  @override
  State<ItemFormBottomSheet> createState() => _ItemFormBottomSheetState();
}

class _ItemFormBottomSheetState extends State<ItemFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;
  late TextEditingController _stockController;
  late TextEditingController _discountController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(text: widget.item?.description);
    _priceController = TextEditingController(text: widget.item?.price.toString());
    _unitController = TextEditingController(text: widget.item?.unit);
    _stockController = TextEditingController(text: widget.item?.stockCount.toString());
    _discountController = TextEditingController(text: widget.item?.discount.toString());
    _imageController = TextEditingController(text: widget.item?.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.item == null) {
        final input = CreateItemInput(
          shopId: widget.shopId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          unit: _unitController.text,
          stockCount: int.parse(_stockController.text),
          imageUrl: _imageController.text,
          discount: double.tryParse(_discountController.text),
        );
        context.read<ItemManagementCubit>().createItem(input);
      } else {
        final input = UpdateItemInput(
          id: widget.item!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          unit: _unitController.text,
          stockCount: int.parse(_stockController.text),
          imageUrl: _imageController.text,
          discount: double.tryParse(_discountController.text),
        );
        context.read<ItemManagementCubit>().updateItem(input);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 12,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item == null ? 'New Product' : 'Product Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showcase your item with precise details and pricing.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      _buildSectionTitle(context, 'PRODUCT IMAGE'),
                      _buildCustomField(context, _imageController, 'Image URL', Icons.add_photo_alternate_rounded),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'CORE SPECIFICATIONS'),
                      _buildCustomField(context, _nameController, 'Product Name', Icons.inventory_2_outlined),
                      _buildCustomField(context, _descriptionController, 'Detailed Description', Icons.description_outlined, maxLines: 3),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'PRICING & STOCK'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCustomField(
                              context,
                              _priceController, 
                              'Price', 
                              Icons.payments_outlined,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCustomField(context, _unitController, 'Unit (e.g. Kg)', Icons.scale_outlined),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCustomField(
                              context,
                              _stockController, 
                              'Total Stock', 
                              Icons.reorder_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCustomField(
                              context,
                              _discountController, 
                              'Discount %', 
                              Icons.percent_rounded,
                              isRequired: false,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildSubmitButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCustomField(
    BuildContext context,
    TextEditingController controller, 
    String label, 
    IconData icon,
    {bool isRequired = true, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: theme.iconTheme.color?.withOpacity(0.3), size: 22),
          hintText: label,
          hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.4), fontWeight: FontWeight.w400),
          filled: true,
          fillColor: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
          ),
          errorStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
        ),
        validator: isRequired ? (value) {
          if (value == null || value.isEmpty) return 'Required';
          return null;
        } : null,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          widget.item == null ? 'List Product' : 'Save Item Details',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
