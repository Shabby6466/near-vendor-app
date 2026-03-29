import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        return SizedBox(
          height: 38,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.mediumHorizontalSpacing(context),
            ),
            scrollDirection: Axis.horizontal,
            itemCount: state is HomeScreenSuccess
                ? state.categories.length
                : (state is HomeScreenLoading
                    ? state.categories.length
                    : (state is HomeScreenFailure
                        ? state.categories.length
                        : 0)),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              late CategoryModel category;
              bool isSelected = false;

              if (state is HomeScreenSuccess) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else if (state is HomeScreenLoading) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else if (state is HomeScreenFailure) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  context.read<HomeScreenCubit>().selectCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.1)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDark
                              ? theme.dividerColor.withValues(alpha: 0.1)
                              : Colors.grey.shade200),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
