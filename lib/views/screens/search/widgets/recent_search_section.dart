import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/views/screens/search/cubit/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/utils/search_navigation.dart';

class RecentSearchSection extends StatelessWidget {
  const RecentSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          current is SearchInitial &&
          (previous is! SearchInitial ||
              previous.recentSearches != current.recentSearches),
      builder: (context, state) {
        if (state is! SearchInitial || state.recentSearches.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentSearches = state.recentSearches;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: ColorName.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<SearchCubit>().clearHistory(),
                    child: Text(
                      'Clear History',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recentSearches.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final keyword = recentSearches[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        SearchNavigation.openResults(
                          context,
                          initialQuery: keyword,
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              keyword,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
