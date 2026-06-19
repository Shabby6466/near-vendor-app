import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/search/search_screen/cubit/search_cubit.dart';
import 'package:nearvendorapp/views/screens/search/search_screen/view/search_results_screen.dart';

class SearchNavigation {
  SearchNavigation._();

  static Future<void> openResults(
    BuildContext context, {
    String? initialQuery,
  }) async {
    await AppNavigator.push(
      context,
      BlocProvider(
        create: (context) => SearchCubit(),
        child: SearchResultsScreen(initialQuery: initialQuery),
      ),
    );

    if (context.mounted) {
      context.read<SearchCubit>().reloadRecentSearches();
    }
  }
}
