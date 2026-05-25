import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

part 'explore_screen_state.dart';

class ExploreScreenCubit extends Cubit<ExploreScreenState>
    with AnalyticsMixin<ExploreScreenState> {
  final ShopServices _shopServices = ShopServices();

  ExploreScreenCubit() : super(ExploreScreenInitial()) {
    _initialize();
    initAnalytics('explore_screen');
  }

  // Variables stored in the Cubit, as requested
  List<Shop> _allShops = [];
  List<CategoryModel> _categories = [CategoryModel.all()];
  CategoryModel _selectedCategory = CategoryModel.all();
  String? _apiMessage;
  String? _searchQuery;

  // Cache for shops by category ID
  final Map<String, List<Shop>> _shopCache = {};

  // Public getters if needed by widgets outside BlocBuilder
  CategoryModel get selectedCategory => _selectedCategory;
  List<Shop> get filteredShops => _allShops;

  Future<void> _initialize() async {
    emit(
      ExploreScreenLoading(
        categories: _categories,
        selectedCategory: _selectedCategory,
      ),
    );
    try {
      final cats = await _shopServices.getCategoryNames();
      _categories = [CategoryModel.all(), ...cats];
      await loadShops();
    } catch (e) {
      emit(
        ExploreScreenFailure(
          e.toString(),
          categories: _categories,
          selectedCategory: _selectedCategory,
        ),
      );
    }
  }

  Future<void> loadShops() async {
    emit(
      ExploreScreenLoading(
        categories: _categories,
        selectedCategory: _selectedCategory,
      ),
    );

    try {
      // Use AppData for location
      final lat = AppData().latitude;
      final lon = AppData().longitude;

      if (lat == null || lon == null) {
        emit(
          ExploreScreenNoLocation(
            categories: _categories,
            selectedCategory: _selectedCategory,
          ),
        );
        return;
      }

      await _fetchShops(lat: lat, lon: lon);
    } catch (e) {
      emit(
        ExploreScreenFailure(
          e.toString(),
          categories: _categories,
          selectedCategory: _selectedCategory,
        ),
      );
    }
  }

  /// Call after the user sets location from the picker.
  Future<void> reloadAfterLocationSet() => loadShops();

  Future<void> _fetchShops({required double lat, required double lon}) async {
    final cacheKey = _selectedCategory.id;

    // Check cache first - only if not searching
    if ((_searchQuery == null || _searchQuery!.isEmpty) &&
        _shopCache.containsKey(cacheKey)) {
      _allShops = _shopCache[cacheKey]!;
      emit(
        ExploreScreenSuccess(
          shops: _allShops,
          categories: _categories,
          selectedCategory: _selectedCategory,
          message: _apiMessage,
        ),
      );
      return;
    }

    try {
      // Use AppData for radius
      final radiusKm = AppData().discoveryRadius ?? 10.0;
      final radius = (radiusKm * 1000).toInt();

      final response = _searchQuery != null && _searchQuery!.isNotEmpty
          ? await _shopServices.searchShops(
              lat: lat,
              lon: lon,
              query: _searchQuery!,
              radius: radius,
            )
          : await _shopServices.getNearbyShops(
              lat: lat,
              lon: lon,
              radius: radius,
              categoryId: _selectedCategory.id,
            );

      if (response.success == true ||
          response.status == 410 ||
          response.status == 404) {
        _apiMessage = (response.status == 410 || response.status == 404)
            ? response.message
            : null;
        _allShops = response.shops;

        // Update cache
        _shopCache[cacheKey] = _allShops;

        emit(
          ExploreScreenSuccess(
            shops: _allShops,
            categories: _categories,
            selectedCategory: _selectedCategory,
            message: _apiMessage,
            isGlobalFallback: response.isGlobalFallback,
            rangeMessage: response.rangeMessage,
          ),
        );
      } else {
        emit(
          ExploreScreenFailure(
            response.message ?? 'An error occurred',
            categories: _categories,
            selectedCategory: _selectedCategory,
          ),
        );
      }
    } catch (e) {
      emit(
        ExploreScreenFailure(
          e.toString(),
          categories: _categories,
          selectedCategory: _selectedCategory,
        ),
      );
    }
  }

  void selectCategory(CategoryModel category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _searchQuery = null; // Clear search when category changes

    // Re-fetch shops with new category
    loadShops();
  }

  void searchShops(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _selectedCategory =
        CategoryModel.all(); // Reset category selection visually during global search
    loadShops();
  }

  void clearSearch() {
    if (_searchQuery == null) return;
    _searchQuery = null;
    loadShops();
  }

  Future<void> refreshShops() async {
    _shopCache.clear();
    await _initialize();
  }

  @override
  Future<void> close() async {
    await closeAnalytics();
    await super.close();
  }
}
