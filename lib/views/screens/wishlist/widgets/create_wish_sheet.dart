import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/categories_service.dart';
import 'package:nearvendorapp/services/wishlist_services.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:toasty_box/toasty_box.dart';

class CreateWishSheet extends StatefulWidget {
  const CreateWishSheet({super.key});

  static Future<void> show(BuildContext context, UserWishlistCubit cubit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const CreateWishSheet()),
    );
  }

  @override
  State<CreateWishSheet> createState() => _CreateWishSheetState();
}

class _CreateWishSheetState extends State<CreateWishSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _loadingCategories = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await CategoriesService.getCategories();
      if (mounted) {
        setState(() {
          _categories = [
            CategoryModel(id: '', name: 'None / Skip'),
            ...response.categories
          ];
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final location = await LocationPickerLauncher.ensureLocation(context);
    if (!mounted || location == null) return;

    setState(() => _isLoading = true);

    final input = CreateWishlistInput(
      itemName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: (_selectedCategory?.id.isNotEmpty ?? false)
          ? _selectedCategory!.id
          : null,
      lat: location.latitude,
      lon: location.longitude,
    );

    final success = await context.read<UserWishlistCubit>().createWishlist(
      input,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      AppNavigator.pop(context);
      ToastService.showSuccessToast(
        context,
        message: 'Wish submitted! We will notify local vendors.',
      );
    } else if (mounted) {
      ToastService.showErrorToast(
        context,
        message: 'Failed to create wish. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171D25) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorName.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: ColorName.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Make a Wish',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g. Organic Raw Honey 1L',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoryModel>(
              initialValue: _selectedCategory,
              hint: _loadingCategories
                  ? const Text('Loading categories...')
                  : const Text('Select Category (Optional)'),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem<CategoryModel>(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: _loadingCategories
                  ? null
                  : (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Any specific brand, color, or detail?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: LoadingAnimation(color: Colors.white, size: 20),
                    )
                  : const Text(
                      'Submit Wish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
