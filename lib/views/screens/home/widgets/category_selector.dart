import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/explore_screen_cubit.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  int _getItemCount(ExploreScreenState state) {
    if (state is ExploreScreenLoading && state.categories.length <= 1) {
      return 5;
    }
    if (state is ExploreScreenSuccess) {
      return state.categories.length;
    }
    if (state is ExploreScreenLoading) {
      return state.categories.length;
    }
    if (state is ExploreScreenFailure) {
      return state.categories.length;
    }
    if (state is ExploreScreenNoLocation) {
      return state.categories.length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ExploreScreenCubit, ExploreScreenState>(
      builder: (context, state) {
        return SizedBox(
          height: 38,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.mediumHorizontalSpacing(context),
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _getItemCount(state),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (state is ExploreScreenLoading && state.categories.length <= 1) {
                return Container(
                  width: 80,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ShimmerEffect(borderRadius: 12),
                );
              }

              late CategoryModel category;
              bool isSelected = false;

              if (state is ExploreScreenSuccess) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else if (state is ExploreScreenLoading) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else if (state is ExploreScreenFailure) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else if (state is ExploreScreenNoLocation) {
                category = state.categories[index];
                isSelected = state.selectedCategory == category;
              } else {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  context.read<ExploreScreenCubit>().selectCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
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
                            : theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.7,
                              ),
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
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
