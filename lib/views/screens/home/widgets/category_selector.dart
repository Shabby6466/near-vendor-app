import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/models/ui_models/categories_list.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/cubit/home_screen_cubit.dart';

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
            itemCount: CategoriesList.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = CategoriesList.categories[index];
              final state = context.watch<HomeScreenCubit>().state;
              final currentCategory = state is HomeScreenSuccess
                  ? state.category
                  : context.read<HomeScreenCubit>().selectedCategory;
              final isSelected = currentCategory == category;

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
                      category,
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
