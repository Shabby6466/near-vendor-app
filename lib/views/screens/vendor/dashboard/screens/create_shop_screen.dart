import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/shop_form_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/vendor_shop_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/cubit/categories_state.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';

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
  final _latController = TextEditingController(text: '22.343434');
  final _longController = TextEditingController(text: '22.343434');
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  File? _logoFile;
  File? _coverFile;
  String? _selectedCategoryId;
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

    final input = CreateShopInput(
      vendorId: vendorId,
      shopName: _nameController.text,
      categoryId: _selectedCategoryId ?? '',
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
      coverFile: _coverFile,
    );
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
            AppAlerts.showSuccessSnackBar(context, 'Your shop is now live!');
            context.read<VendorShopCubit>().fetchShops();
            AppNavigator.pop(context);
          } else if (state is ShopFormFailure) {
            AppAlerts.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return AppScaffold(
            appBar: AppBar(
              title: const Text(
                'Business Identity',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => AppNavigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Launch Shop',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
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
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: (0.5),
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSectionTitle(context, 'BRANDING & MEDIA'),
                    _buildFormHelper('Visuals are the first thing customers see. High-quality logos and covers increase trust by up to 40%.'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMediaField(
                            context,
                            'Store Logo',
                            _logoFile,
                            null,
                            () => _pickImage(true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMediaField(
                            context,
                            'Cover Photo',
                            _coverFile,
                            null,
                            () => _pickImage(false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'CORE INFORMATION'),
                    _buildCustomField(
                      context,
                      _nameController,
                      'Business Name',
                      Icons.storefront_rounded,
                      helperText: 'Choose a name that is easy to remember and search for.',
                    ),
                    _buildCategoryDropdownField(context),
                    _buildCustomField(
                      context,
                      _regNumberController,
                      'Tax / Reg Number',
                      Icons.verified_user_outlined,
                      helperText: 'Required for verification and to build credibility with customers.',
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'CONTACT & REACH'),
                    _buildCustomField(
                      context,
                      _addressController,
                      'Physical Address',
                      Icons.location_on_outlined,
                    ),
                    _buildLocationPickerField(context),
                    _buildCustomField(
                      context,
                      _phoneController,
                      'Contact Phone',
                      Icons.phone_iphone_rounded,
                    ),
                    _buildCustomField(
                      context,
                      _whatsappController,
                      'WhatsApp Business (Optional)',
                      Icons.chat_bubble_outline_rounded,
                      isRequired: false,
                    ),
                    _buildCustomField(
                      context,
                      _emailController,
                      'Support Email',
                      Icons.mail_outline_rounded,
                    ),

                    const SizedBox(height: 48),
                    _buildSubmitButton(context, state),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildFormHelper(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          height: 1.4,
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
        List<CategoryModel> categories = [];
        bool isLoading = false;

        if (state is CategoriesLoaded) {
          categories = state.categories;
        } else if (state is CategoriesLoading) {
          isLoading = true;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
            dropdownColor: theme.cardColor,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.work_outline_rounded,
                color: theme.iconTheme.color?.withValues(alpha: (0.3)),
                size: 22,
              ),
              hintText: isLoading
                  ? 'Loading categories...'
                  : 'Industry / Category',
              hintStyle: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: (0.4),
                ),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1C1C23)
                  : const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
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
            items: categories.map((CategoryModel category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            }).toList(),
            onChanged: isLoading
                ? null
                : (String? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                      if (newValue != null) {
                        _categoryController.text = categories
                            .firstWhere((c) => c.id == newValue)
                            .name;
                      }
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
    IconData icon, {
    bool isRequired = true,
    String? helperText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: theme.iconTheme.color?.withValues(alpha: (0.3)),
                size: 22,
              ),
              hintText: label,
              hintStyle: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: (0.4)),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1C1C23) : const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
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
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty)
                      return 'This field is required';
                    return null;
                  }
                : null,
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                helperText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaField(
    BuildContext context,
    String label,
    File? file,
    String? networkUrl,
    VoidCallback onTap,
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
              color: theme.textTheme.bodyMedium?.color?.withValues(
                alpha: (0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C23)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: (0.1)),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : (networkUrl != null && networkUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: networkUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) =>
                            const Icon(Icons.image),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: theme.primaryColor.withValues(alpha: (0.5)),
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: (0.4)),
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
            color: theme.primaryColor.withValues(alpha: (0.3)),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
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
            : const Text(
                'Launch Business',
                style: TextStyle(
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
          final LatLng? result = await AppNavigator.push(
            context,
            LocationPickerScreen(),
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
              Icon(
                Icons.map_outlined,
                color: theme.iconTheme.color?.withValues(alpha: (0.3)),
                size: 22,
              ),
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
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: (0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _latController.text.isEmpty ||
                              _longController.text.isEmpty
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
              Icon(
                Icons.chevron_right_rounded,
                color: theme.iconTheme.color?.withValues(alpha: (0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
