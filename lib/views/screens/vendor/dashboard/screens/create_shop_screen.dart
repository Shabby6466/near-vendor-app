import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_state.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_state.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

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
  final _latController = TextEditingController(text: '22.343434');
  final _longController = TextEditingController(text: '22.343434');

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _regNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _latController.dispose();
    _longController.dispose();
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
        shopLongitude: double.tryParse(_longController.text) ?? 22.343434,
        shopLatitude: double.tryParse(_latController.text) ?? 22.343434,
        shopContactPhone: _phoneController.text,
        whatsappNumber: _whatsappController.text,
        storeEmail: _emailController.text,
      );

      context.read<ShopCubit>().createShop(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesCubit()..fetchCategories(),
      child: BlocListener<ShopCubit, ShopState>(
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
            title: const Text(
              'Create New Shop',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
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
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildLocationPickerField(context),
                  const SizedBox(height: 16),
                  _buildTextField('Registration Number', _regNumberController),
                  const SizedBox(height: 16),
                  _buildTextField('Shop Address', _addressController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Contact Phone',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'WhatsApp Number',
                    _whatsappController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Store Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
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
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        List<String> categories = [];
        bool isLoading = false;

        if (state is CategoriesLoaded) {
          categories = state.categories;
        } else if (state is CategoriesLoading) {
          isLoading = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categoryController.text.isEmpty ? null : _categoryController.text,
              hint: Text(isLoading ? 'Loading categories...' : 'Select Category'),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _categoryController.text = newValue ?? '';
                      });
                    },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
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
                  return 'Please select a category';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
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

  Widget _buildLocationPickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final LatLng? result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LocationPickerScreen()),
            );
            if (result != null) {
              setState(() {
                _latController.text = result.latitude.toStringAsFixed(6);
                _longController.text = result.longitude.toStringAsFixed(6);
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: Colors.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _latController.text.isEmpty || _longController.text.isEmpty
                        ? 'Tap to select location on map'
                        : '${_latController.text}, ${_longController.text}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
