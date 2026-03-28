import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class RecentSearchSection extends StatelessWidget {
  const RecentSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) => current is SearchInitial,
      builder: (context, state) {
        if (state is! SearchInitial || state.recentSearches.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentSearches = state.recentSearches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.mediumHorizontalSpacing(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Search',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<SearchCubit>().clearHistory(),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.mediumHorizontalSpacing(context),
                ),
                scrollDirection: Axis.horizontal,
                itemCount: recentSearches.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final keyword = recentSearches[index];
                  return ActionChip(
                    label: Text(
                      keyword,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    onPressed: () {
                      final sessionState = context.read<SessionCubit>().state;
                      context.read<SearchCubit>().searchItems(
                            lat: sessionState.latitude ?? 0.0,
                            lon: sessionState.longitude ?? 0.0,
                            query: keyword,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
