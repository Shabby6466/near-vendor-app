import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/api_inputs/search_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
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
    if (CurrentUserStorage.getUserAuthToken() != null) {
      final response = await _searchServices.getRecentItems();
      if (response.success) {
        emit(SearchInitial(
          recentSearches: recentSearches,
          recentItems: response.items,
        ));
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

    emit(const SearchLoading());

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

    if (response.success) {
      updateAnalyticsMetadata({
        'lat': lat,
        'lon': lon,
        'query': query,
      });
      emit(SearchSuccess(
        items: response.items,
        meta: response.meta,
        message: response.message,
      ));
    } else {
      emit(SearchFailure(response.message ?? 'Search failed'));
    }
  }

  void clearSearch() {
    loadInitialData();
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
