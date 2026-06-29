import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/wishlist/create_wish_sheet/cubit/create_wish_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class CreateWishSheet extends StatelessWidget {
  const CreateWishSheet({super.key});

  static Future<void> show(BuildContext context) {
    UserWishlistCubit? userWishlistCubit;
    try {
      userWishlistCubit = context.read<UserWishlistCubit>();
    } catch (_) {}

    return AppBottomSheet.showBottomSheet(
      context: context,
      isScrollControlled: true,
      padding: EdgeInsets.zero,
      child: MultiBlocProvider(
        providers: [
          if (userWishlistCubit != null)
            BlocProvider.value(value: userWishlistCubit),
          BlocProvider(
            create: (context) => CreateWishCubit()..loadCategories(),
          ),
        ],
        child: const CreateWishSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateWishCubit, CreateWishState>(
      listener: (context, state) {
        if (state is CreateWishSuccess) {
          try {
            context.read<UserWishlistCubit>().getMyWishlists(refresh: true);
          } catch (e) {
            debugPrint('UserWishlistCubit not found in context: $e');
          }
          AppAlerts.showSuccess(
            context,
            'Wish submitted! We will notify local vendors.',
          );
          AppNavigator.pop(context);
        } else if (state is CreateWishFailure) {
          AppAlerts.showError(context, state.message);
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
                InkWell(
                  onTap: state is! CreateWishCategoriesLoaded
                      ? null
                      : () => _showCategorySheet(context, cubit),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: state is! CreateWishCategoriesLoaded
                          ? 'Loading categories...'
                          : 'Select Category (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    isEmpty: cubit.selectedCategory == null,
                    child: Text(
                      cubit.selectedCategory?.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
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

  Future<void> _showCategorySheet(BuildContext context, CreateWishCubit cubit) async {
    final selected = await AppBottomSheet.showBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorName.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: ColorName.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Helps vendors match your wish faster',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AppNavigator.pop(context, CategoryModel(id: '', name: 'None / Skip'));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: cubit.selectedCategory == null
                        ? ColorName.primary
                        : Colors.redAccent,
                  ),
                  child: Text(
                    cubit.selectedCategory == null ? 'Skip' : 'Clear',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cubit.categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final cat = cubit.categories[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final isSelected = cubit.selectedCategory?.id == cat.id;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: isSelected,
                    selectedTileColor: ColorName.primary.withValues(alpha: 0.08),
                    title: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? ColorName.primary
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: ColorName.primary, size: 20)
                        : Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: isDark ? Colors.white24 : Colors.grey.shade400,
                          ),
                    onTap: () => AppNavigator.pop(context, cat),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      if (selected.id.isEmpty) {
        cubit.selectCategory(null);
      } else {
        cubit.selectCategory(selected);
      }
    }
  }
}
