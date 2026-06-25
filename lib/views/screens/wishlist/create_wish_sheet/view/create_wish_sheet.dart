import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/wishlist/create_wish_sheet/cubit/create_wish_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:toasty_box/toasty_box.dart';

class CreateWishSheet extends StatelessWidget {
  const CreateWishSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showBottomSheet(
      context: context,
      isScrollControlled: true,
      child: BlocProvider(
        create: (context) => CreateWishCubit()..loadCategories(),
        child: const CreateWishSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWishCubit, CreateWishState>(
      listener: (context, state) {
        if (state is CreateWishSuccess) {
          context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
          AppNavigator.pop(context);
          ToastService.showSuccessToast(
            context,
            message: 'Wish submitted! We will notify local vendors.',
          );
        } else if (state is CreateWishFailure) {
          ToastService.showErrorToast(context, message: state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateWishCubit>();
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isLoading = state is CreateWishSubmitting;

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
            key: cubit.formKey,
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
                  controller: cubit.nameController,
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
                  initialValue: cubit.selectedCategory,
                  hint: state is! CreateWishCategoriesLoaded
                      ? const Text('Loading categories...')
                      : const Text('Select Category (Optional)'),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: cubit.categories.map((c) {
                    return DropdownMenuItem<CategoryModel>(
                      value: c,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: state is! CreateWishCategoriesLoaded
                      ? null
                      : (val) => cubit.selectCategory(val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cubit.descriptionController,
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
                  onPressed: isLoading ? null : () => cubit.submit(context),
                  style: ElevatedButton.styleFrom(elevation: 0),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: LoadingAnimation(
                            color: Colors.white,
                            size: 20,
                          ),
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
      },
    );
  }
}
