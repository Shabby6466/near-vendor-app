import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        return SizedBox(
          height: 45,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.mediumHorizontalSpacing(context),
              vertical: 4,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: state is HomeScreenSuccess
                ? state.categories.length
                : (state is HomeScreenLoading
                    ? state.categories.length
                    : (state is HomeScreenFailure
                        ? state.categories.length
                        : 0)),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorName.secondary
                        : ColorName.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
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
