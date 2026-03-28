import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/search/search_cubit.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_items_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/recent_search_section.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_bar_field.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_filter_chips.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_header.dart';
import 'package:nearvendorapp/views/screens/search/widgets/search_results_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SearchHeader(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                    const SearchBarField(),
                    SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                    const SearchFilterChips(),
                    SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                    BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        if (state is SearchInitial) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RecentSearchSection(),
                              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                              RecentItemsSection(),
                            ],
                          );
                        }
                        return const SearchResultsList();
                      },
                    ),
                    SizedBox(height: AppSpacing.extraLargeVerticalSpacing(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
