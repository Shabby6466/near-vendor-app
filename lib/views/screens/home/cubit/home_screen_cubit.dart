import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState>
    with AnalyticsMixin<HomeScreenState> {
  final ShopServices _shopServices = ShopServices();

  HomeScreenCubit() : super(HomeScreenInitial()) {
    _initialize();
    initAnalytics('home_screen');
  }

  // Variables stored in the Cubit, as requested
  List<ShopModel> _allShops = [];
  List<CategoryModel> _categories = [CategoryModel.all()];
  CategoryModel _selectedCategory = CategoryModel.all();
  String? _apiMessage;
  String? _searchQuery;

  // Cache for shops by category ID
  final Map<String, List<ShopModel>> _shopCache = {};

  // Public getters if needed by widgets outside BlocBuilder
  CategoryModel get selectedCategory => _selectedCategory;
  List<ShopModel> get filteredShops => _allShops;

  Future<void> _initialize() async {
    // Fetch categories first
    final cats = await _shopServices.getCategoryNames();
    _categories = [CategoryModel.all(), ...cats];
    await loadShops();
  }

  Future<void> loadShops() async {
    emit(
      HomeScreenLoading(
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
          HomeScreenNoLocation(
            categories: _categories,
            selectedCategory: _selectedCategory,
          ),
        );
        return;
      }

      await _fetchShops(lat: lat, lon: lon);
    } catch (e) {
      emit(
        HomeScreenNoLocation(
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
        HomeScreenSuccess(
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
        _allShops = response.shops
            .map((shop) => _mapToShopModel(shop))
            .toList();

        // Update cache
        _shopCache[cacheKey] = _allShops;

        emit(
          HomeScreenSuccess(
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
          HomeScreenFailure(
            response.message ?? 'An error occurred',
            categories: _categories,
            selectedCategory: _selectedCategory,
          ),
        );
      }
    } catch (e) {
      emit(
        HomeScreenFailure(
          e.toString(),
          categories: _categories,
          selectedCategory: _selectedCategory,
        ),
      );
    }
  }

  ShopModel _mapToShopModel(Shop shop) {
    return ShopModel(
      id: shop.id,
      vendorId: shop.vendorId,
      name: shop.shopName,
      image: shop.coverImageUrl ?? '',
      category: shop.businessCategory,
      latitude: shop.shopLatitude,
      longitude: shop.shopLongitude,
      location: shop.shopAddress,
      itemCount: shop.itemCount,
      isVerifiedBadge: shop.isVerifiedBadge,
      isRecentlyActive: shop.isRecentlyActive,
      distance: shop.distance,
    );
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
