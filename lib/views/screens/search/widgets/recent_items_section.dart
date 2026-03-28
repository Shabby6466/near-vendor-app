import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/item_card.dart';

class RecentItemsSection extends StatelessWidget {
  const RecentItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) => current is SearchInitial,
      builder: (context, state) {
        if (state is! SearchInitial || state.recentItems.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentItems = state.recentItems;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.mediumHorizontalSpacing(context),
              ),
              child: Text(
                'Recently Viewed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.mediumHorizontalSpacing(context),
                ),
                scrollDirection: Axis.horizontal,
                itemCount: recentItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return ItemCard(
                    item: recentItems[index],
                    width: 160,
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
          ],
        );
      },
    );
  }
}
