import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_form_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_state.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

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
  
  File? _logoFile;
  File? _coverFile;
  final _picker = ImagePicker();

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
      );
      context.read<ShopFormCubit>().createShop(
        input, 
        logoFile: _logoFile, 
        coverFile: _coverFile
      );
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
        storeLogoUrl: widget.shop?.storeLogoUrl,
        coverImageUrl: widget.shop?.coverImageUrl,
        isActive: widget.shop?.isActive,
      );
      context.read<ShopFormCubit>().updateShop(
        input, 
        logoFile: _logoFile, 
        coverFile: _coverFile
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ShopFormCubit()),
        BlocProvider(create: (context) => CategoriesCubit()..fetchCategories()),
      ],
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
                                 Row(
                                   children: [
                                     Expanded(
                                       child: _buildMediaField(
                                         context, 
                                         'Store Logo', 
                                         _logoFile, 
                                         widget.shop?.storeLogoUrl,
                                         () => _pickImage(true),
                                         false
                                       ),
                                     ),
                                     const SizedBox(width: 16),
                                     Expanded(
                                       child: _buildMediaField(
                                         context, 
                                         'Cover Photo', 
                                         _coverFile, 
                                         widget.shop?.coverImageUrl,
                                         () => _pickImage(false),
                                         true
                                       ),
                                     ),
                                   ],
                                 ),
                                
                                const SizedBox(height: 24),
                                _buildSectionTitle(context, 'CORE INFORMATION'),
                                _buildCustomField(context, _nameController, 'Business Name', Icons.storefront_rounded),
                                _buildCategoryDropdownField(context),
                                _buildCustomField(context, _regNumberController, 'Tax / Reg Number', Icons.verified_user_outlined),
                                
                                const SizedBox(height: 24),
                                _buildSectionTitle(context, 'CONTACT & REACH'),
                                _buildCustomField(context, _addressController, 'Physical Address', Icons.location_on_outlined),
                                _buildLocationPickerField(context),
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

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(image.path);
        } else {
          _coverFile = File(image.path);
        }
      });
    }
  }

  Widget _buildCategoryDropdownField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        List<String> categories = [];
        bool isLoading = false;

        if (state is CategoriesLoaded) {
          categories = state.categories;
        } else if (state is CategoriesLoading) {
          isLoading = true;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DropdownButtonFormField<String>(
            value: (categories.contains(_categoryController.text))
                ? _categoryController.text
                : null,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black),
            dropdownColor: theme.cardColor,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.work_outline_rounded,
                  color: theme.iconTheme.color?.withOpacity(0.3), size: 22),
              hintText: isLoading ? 'Loading categories...' : 'Industry / Category',
              hintStyle: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                  fontWeight: FontWeight.w400),
              filled: true,
              fillColor: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category,
                    style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontFamily: 'Poppins')),
              );
            }).toList(),
            onChanged: isLoading
                ? null
                : (String? newValue) {
                    setState(() {
                      _categoryController.text = newValue ?? '';
                    });
                  },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        );
      },
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

  Widget _buildMediaField(
    BuildContext context, 
    String label, 
    File? file, 
    String? networkUrl, 
    VoidCallback onTap,
    bool isWide,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : (networkUrl != null && networkUrl.isNotEmpty)
                        ? Image.network(networkUrl, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: theme.primaryColor.withOpacity(0.5),
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
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
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    state.message ?? 'Processing...',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  Widget _buildLocationPickerField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async {
          final LatLng? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
          );
          if (result != null) {
            setState(() {
              _latController.text = result.latitude.toStringAsFixed(6);
              _longController.text = result.longitude.toStringAsFixed(6);
            });
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(Icons.map_outlined,
                  color: theme.iconTheme.color?.withOpacity(0.3), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Location',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _latController.text.isEmpty || _longController.text.isEmpty
                          ? 'Tap to select location'
                          : '${_latController.text}, ${_longController.text}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.iconTheme.color?.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
