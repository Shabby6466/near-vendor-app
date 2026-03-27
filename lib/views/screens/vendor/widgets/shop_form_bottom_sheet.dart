import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_form_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';

class ShopFormBottomSheet extends StatefulWidget {
  final Shop? shop;

  const ShopFormBottomSheet({super.key, this.shop});

  @override
  State<ShopFormBottomSheet> createState() => _ShopFormBottomSheetState();
}

class _ShopFormBottomSheetState extends State<ShopFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _regNumberController;
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _longController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _logoController;
  late final TextEditingController _coverController;

  final Map<String, String> _operatingHours = {
    'mon': '09:00-18:00',
    'tue': '09:00-18:00',
    'wed': '09:00-18:00',
    'thu': '09:00-18:00',
    'fri': '09:00-18:00',
    'sat': '09:00-18:00',
    'sun': 'Closed',
  };

  @override
  void initState() {
    super.initState();
    final s = widget.shop;
    _nameController = TextEditingController(text: s?.shopName);
    _categoryController = TextEditingController(text: s?.businessCategory);
    _regNumberController = TextEditingController(text: s?.registrationNumber);
    _addressController = TextEditingController(text: s?.shopAddress);
    _latController = TextEditingController(text: s?.shopLatitude.toString() ?? '22.343434');
    _longController = TextEditingController(text: s?.shopLongitude.toString() ?? '22.343434');
    _phoneController = TextEditingController(text: s?.shopContactPhone);
    _whatsappController = TextEditingController(text: s?.whatsappNumber);
    _emailController = TextEditingController(text: s?.storeEmail);
    _logoController = TextEditingController(text: s?.storeLogoUrl);
    _coverController = TextEditingController(text: s?.coverImageUrl);
    
    if (s != null) {
      _operatingHours.addAll(s.operatingHours.cast<String, String>());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _regNumberController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _logoController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionCubit>().state;
    final vendorId = session.user?.id ?? 'vendorId';
    
    if (widget.shop == null) {
      final input = CreateShopInput(
        vendorId: vendorId,
        shopName: _nameController.text,
        businessCategory: _categoryController.text,
        registrationNumber: _regNumberController.text,
        shopAddress: _addressController.text,
        operatingHours: _operatingHours,
        shopLongitude: double.tryParse(_longController.text) ?? 0.0,
        shopLatitude: double.tryParse(_latController.text) ?? 0.0,
        shopContactPhone: _phoneController.text,
        whatsappNumber: _whatsappController.text,
        storeEmail: _emailController.text,
        storeLogoUrl: _logoController.text,
        coverImageUrl: _coverController.text,
      );
      context.read<ShopFormCubit>().createShop(input);
    } else {
      final input = UpdateShopInput(
        vendorId: vendorId,
        shopName: _nameController.text,
        businessCategory: _categoryController.text,
        registrationNumber: _regNumberController.text,
        shopAddress: _addressController.text,
        operatingHours: _operatingHours,
        shopLongitude: double.tryParse(_longController.text),
        shopLatitude: double.tryParse(_latController.text),
        shopContactPhone: _phoneController.text,
        whatsappNumber: _whatsappController.text,
        storeEmail: _emailController.text,
        storeLogoUrl: _logoController.text,
        coverImageUrl: _coverController.text,
        isActive: widget.shop?.isActive,
      );
      context.read<ShopFormCubit>().updateShop(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => ShopFormCubit(),
      child: BlocConsumer<ShopFormCubit, ShopFormState>(
        listener: (context, state) {
          if (state is ShopFormSuccess) {
            AppAlerts.showSuccessSnackBar(
              context, 
              state.isUpdate ? 'Business identity updated!' : 'Your shop is now live!'
            );
            context.read<VendorShopCubit>().fetchShops();
            AppNavigator.pop(context);
          } else if (state is ShopFormFailure) {
            AppAlerts.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 12),
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
                          padding: EdgeInsets.fromLTRB(28, 24, 28, MediaQuery.of(context).viewInsets.bottom + 40),
                          physics: const BouncingScrollPhysics(),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.shop == null ? 'Business Identity' : 'Profile Settings',
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
                                  'Curate your shop details to stand out in the marketplace.',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                
                                _buildSectionTitle(context, 'BRANDING & MEDIA'),
                                _buildMediaField(context, 'Store Logo', _logoController, Icons.insert_photo_rounded),
                                _buildMediaField(context, 'Cover Photo', _coverController, Icons.wallpaper_rounded),
                                
                                const SizedBox(height: 24),
                                _buildSectionTitle(context, 'CORE INFORMATION'),
                                _buildCustomField(context, _nameController, 'Business Name', Icons.storefront_rounded),
                                _buildCustomField(context, _categoryController, 'Industry / Category', Icons.work_outline_rounded),
                                _buildCustomField(context, _regNumberController, 'Tax / Reg Number', Icons.verified_user_outlined),
                                
                                const SizedBox(height: 24),
                                _buildSectionTitle(context, 'CONTACT & REACH'),
                                _buildCustomField(context, _addressController, 'Physical Address', Icons.location_on_outlined),
                                Row(
                                  children: [
                                    Expanded(child: _buildCustomField(context, _latController, 'Latitude', Icons.map_outlined)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildCustomField(context, _longController, 'Longitude', Icons.map_outlined)),
                                  ],
                                ),
                                _buildCustomField(context, _phoneController, 'Contact Phone', Icons.phone_iphone_rounded),
                                _buildCustomField(context, _whatsappController, 'WhatsApp Business (Optional)', Icons.chat_bubble_outline_rounded, isRequired: false),
                                _buildCustomField(context, _emailController, 'Support Email', Icons.mail_outline_rounded),
                                
                                const SizedBox(height: 48),
                                _buildSubmitButton(context, state),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    {bool isRequired = true}
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
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
          if (value == null || value.isEmpty) return 'This field is required';
          return null;
        } : null,
      ),
    );
  }

  Widget _buildMediaField(BuildContext context, String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomField(context, controller, label, icon),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ShopFormState state) {
    final theme = Theme.of(context);
    final isLoading = state is ShopFormLoading;
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
        onPressed: isLoading ? null : () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(
                widget.shop == null ? 'Launch Business' : 'Update Profile',
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
