import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildImageUpload(context),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            _buildLabel(context, 'Product Name'),
            const AppTextField(hint: 'e.g. Organic Arabica Coffee'),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildLabel(context, 'Category'),
            _buildDropdown(context, 'Select a category'),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context, 'Price (\$)'),
                      const AppTextField(hint: '0.00', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context, 'Stock Quantity'),
                      const AppTextField(hint: '0', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _buildLabel(context, 'Description (Optional)'),
            const AppTextField(
              hint: 'Tell customers more about your item...',
              isMultiline: true,
            ),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            AppElevatedButton(
              onPressed: () {
                // Handle product addition
                Navigator.pop(context);
              },
              text: 'Add to Catalog',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1), style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          const Text('Upload product photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('PNG, JPG up to 10MB', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          items: ['Food', 'Beverages', 'Electronics', 'Clothing'].map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }
}
