import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/wishlist/create_wish_screen/cubit/create_wish_cubit.dart';
import 'package:nearvendorapp/views/screens/wishlist/cubit/user_wishlist_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class CreateWishScreen extends StatelessWidget {
  const CreateWishScreen({super.key});

  static Future<void> push(BuildContext context) {
    UserWishlistCubit? userWishlistCubit;
    try {
      userWishlistCubit = context.read<UserWishlistCubit>();
    } catch (_) {}

    return AppNavigator.push(
      context,
      MultiBlocProvider(
        providers: [
          if (userWishlistCubit != null)
            BlocProvider.value(value: userWishlistCubit),
          BlocProvider(
            create: (context) => CreateWishCubit()..loadCategories(),
          ),
        ],
        child: const CreateWishScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        final isSubmitting = state is CreateWishSubmitting;

        return LoadingScreenView(
          isLoading: isSubmitting,
          child: Scaffold(
            appBar: AppBar(title: const Text('Make a Wish')),
            body: SingleChildScrollView(
              padding: AppSpacing.screenPadding(context),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        'Product Name',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                    AppTextField(
                      controller: cubit.nameController,
                      hint: 'e.g. Organic Raw Honey 1L',
                      showBorder: true,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Product name is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        'Category',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: state is! CreateWishCategoriesLoaded
                          ? null
                          : () => _showCategorySheet(context, cubit),
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: TextEditingController(
                            text: cubit.selectedCategory?.name ?? '',
                          ),
                          hint: state is! CreateWishCategoriesLoaded
                              ? 'Loading categories...'
                              : 'Select Category (Optional)',
                          showBorder: true,
                          prefixIcon: const Icon(Icons.category_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        'Description (Optional)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ),
                    AppTextField(
                      controller: cubit.descriptionController,
                      hint: 'Any specific brand, color, or detail?',
                      showBorder: true,
                      isMultiline: true,
                    ),
                    const SizedBox(height: 48),

                    AppElevatedButton(
                      onPressed: () => cubit.submit(context),
                      text: 'Submit Wish',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCategorySheet(
    BuildContext context,
    CreateWishCubit cubit,
  ) async {
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
                    AppNavigator.pop(
                      context,
                      CategoryModel(id: '', name: 'None / Skip'),
                    );
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
                    selectedTileColor: ColorName.primary.withValues(
                      alpha: 0.08,
                    ),
                    title: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? ColorName.primary
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: ColorName.primary,
                            size: 20,
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade400,
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
