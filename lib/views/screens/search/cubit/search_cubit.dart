import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/api_request_models/search_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/hive/search_storage.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> with AnalyticsMixin<SearchState> {
  final SearchServices _searchServices = SearchServices();

  SearchCubit() : super(const SearchInitial()) {
    loadInitialData();
    initAnalytics('search_screen');
  }

  Future<void> loadInitialData() async {
    final recentSearches = SearchStorage.getRecentSearches();

    // Show initial state with local searches first (fast)
    emit(SearchInitial(recentSearches: recentSearches));

    // Fetch recent items from API only if authenticated
    if (AppData().token != null) {
      final response = await _searchServices.getRecentItems();
      if (response.success == true) {
        emit(
          SearchInitial(
            recentSearches: recentSearches,
            recentItems: response.items,
          ),
        );
      }
    }
  }

  Future<void> searchItems({
    required double lat,
    required double lon,
    required String query,
    String? categoryId,
    String? shopId,
    int? radius,
    int page = 1,
    int limit = 10,
  }) async {
    if (query.isEmpty && categoryId == null && shopId == null) {
      loadInitialData();
      return;
    }

    emit(SearchLoading());

    // Save search history if query is not empty
    if (query.isNotEmpty) {
      await SearchStorage.addRecentSearch(query);
    }

    // Get persisted discovery radius (km) and convert to units (1km = 1000 units)
    final storedRadiusKm = CurrentUserStorage.getDiscoveryRadius();
    final finalRadius = radius ?? (storedRadiusKm * 1000).toInt();

    final input = SearchItemInput(
      lat: lat,
      lon: lon,
      query: query,
      radius: finalRadius,
      page: page,
      limit: limit,
      categoryId: categoryId,
      shopId: shopId,
    );

    final response = await _searchServices.searchItems(input);

    if (response.success ?? false) {
      updateAnalyticsMetadata({'lat': lat, 'lon': lon, 'query': query});
      emit(
        SearchSuccess(
          items: response.items,
          meta: response.meta,
          message: response.message,
          query: query.isNotEmpty ? query : null,
          isGlobalFallback: response.isGlobalFallback,
          rangeMessage: response.rangeMessage,
        ),
      );
    } else {
      emit(SearchFailure(response.message ?? 'Search failed'));
    }
  }

  void clearSearch() {
    loadInitialData();
  }

  /// Reloads recent searches from local storage without refetching API data.
  void reloadRecentSearches() {
    final recentSearches = SearchStorage.getRecentSearches();
    final current = state;

    if (current is SearchInitial) {
      emit(
        SearchInitial(
          recentSearches: recentSearches,
          recentItems: current.recentItems,
        ),
      );
    } else {
      loadInitialData();
    }
  }

  Future<void> clearHistory() async {
    await SearchStorage.clearRecentSearches();
    loadInitialData();
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
