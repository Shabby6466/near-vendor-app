import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/analytics/analytics_controller.dart';
import 'package:nearvendorapp/analytics/analytics_event.dart';
import 'package:nearvendorapp/models/api_request_models/search_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';
import 'package:nearvendorapp/services/search_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/hive/search_storage.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchServices _searchServices = SearchServices();
  Timer? _debounceTimer;

  SearchCubit() : super(const SearchInitial()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final recentSearches = SearchStorage.getRecentSearches();

    // Show initial state with local searches first (fast)
    emit(SearchInitial(recentSearches: recentSearches));

    // Fetch recent items from API only if authenticated
    if (AppData().token != null) {
      final response = await _searchServices.getRecentItems();
      if (response.isSuccess) {
        emit(
          SearchInitial(
            recentSearches: recentSearches,
            recentProducts: response.products,
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
    bool saveToHistory = true,
  }) async {
    if (query.isEmpty && categoryId == null && shopId == null) {
      loadInitialData();
      return;
    }

    if (state is! SearchSuccess) {
      emit(SearchLoading());
    }

    // Save search history if query is not empty and requested
    if (query.isNotEmpty && saveToHistory) {
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

    try {
      final response = await _searchServices.searchItems(input);

      if (response.isSuccess) {
        AnalyticsController.instance.recordEvent(
          BuyerAnalyticsEvent.searchPerformed,
          targetId: query,
          data: {'lat': lat, 'lon': lon},
        );
        emit(
          SearchSuccess(
            products: response.products,
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
    } catch (e) {
      emit(SearchFailure(e.toString()));
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
          recentProducts: current.recentProducts,
        ),
      );
    } else {
      loadInitialData();
    }
  }

  Future<void> clearHistory() async {
    await SearchStorage.clearRecentSearches();
    reloadRecentSearches();
  }

  /// Clears the recently viewed products both locally (UI) and on the server.
  /// The UI is updated optimistically before the API call completes.
  Future<void> clearRecentItems() async {
    final current = state;
    if (current is SearchInitial) {
      // Optimistic update — hide items immediately
      emit(SearchInitial(recentSearches: current.recentSearches));
    }
    await _searchServices.clearRecentItems();
  }

  /// Debounces typing before triggering a search.
  /// Uses stale-while-reloading to avoid jarring screen blanking.
  void onQueryChanged(
    String query, {
    required double lat,
    required double lon,
  }) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    if (trimmed.length < 2) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      searchItems(lat: lat, lon: lon, query: trimmed, saveToHistory: false);
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
