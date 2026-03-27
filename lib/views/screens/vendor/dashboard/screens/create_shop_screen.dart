import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_state.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _regNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = CurrentUserStorage.getCurrentUser();
      if (user?.id == null) {
        AppAlerts.showErrorSnackBar(context, 'User session not found');
        return;
      }

      final input = CreateShopInput(
        vendorId: user!.id!,
        shopName: _nameController.text,
        businessCategory: _categoryController.text.toLowerCase(),
        registrationNumber: _regNumberController.text,
        shopAddress: _addressController.text,
        operatingHours: {
          "mon": "09:00-18:00",
          "tue": "09:00-18:00",
          "wed": "09:00-18:00",
          "thu": "09:00-18:00",
          "fri": "09:00-18:00",
        },
        shopLongitude: 0.0,
        shopLatitude: 0.0,
        shopContactPhone: _phoneController.text,
        whatsappNumber: _whatsappController.text,
        storeEmail: _emailController.text,
      );

      context.read<ShopCubit>().createShop(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopCubit, ShopState>(
      listener: (context, state) {
        if (state is ShopActionSuccess) {
          AppAlerts.showSuccessSnackBar(context, state.message);
          AppNavigator.pop(context);
        } else if (state is ShopFailure) {
          AppAlerts.showErrorSnackBar(context, state.error);
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          title: const Text('Create New Shop', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Shop Name', _nameController),
                const SizedBox(height: 16),
                _buildTextField('Business Category (e.g. food)', _categoryController),
                const SizedBox(height: 16),
                _buildTextField('Registration Number', _regNumberController),
                const SizedBox(height: 16),
                _buildTextField('Shop Address', _addressController),
                const SizedBox(height: 16),
                _buildTextField('Contact Phone', _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('WhatsApp Number', _whatsappController, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('Store Email', _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 32),
                BlocBuilder<ShopCubit, ShopState>(
                  builder: (context, state) {
                    return AppElevatedButton(
                      onPressed: state is ShopLoading ? null : _submit,
                      text: state is ShopLoading ? 'Creating...' : 'Create Shop',
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

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorName.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
