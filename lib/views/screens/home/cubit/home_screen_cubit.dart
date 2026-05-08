import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/cubits/analytics_mixin.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart' as data;
import 'package:nearvendorapp/models/ui_models/shop_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

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
      final lastLoc = CurrentUserStorage.getLastLocation();
      if (lastLoc != null) {
        await _fetchShops(lat: lastLoc['lat']!, lon: lastLoc['lon']!);
        return;
      }
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleNoLocationFound();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleNoLocationFound();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleNoLocationFound();
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      // Store GPS location as the global set location
      await CurrentUserStorage.setLastLocation(
        position.latitude,
        position.longitude,
      );

      // Sync with SessionCubit so other screens (like the Map) update immediately
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.read<SessionCubit>().updateManualLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      updateAnalyticsMetadata({
        'lat': position.latitude,
        'lon': position.longitude,
      });

      await _fetchShops(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      _handleNoLocationFound();
    }
  }

  void _handleNoLocationFound() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      AppAlerts.showErrorSnackBar(
        context,
        'Location not found. Please set it manually.',
      );
      AppBottomSheet.openLocationSet();
    }

    // Fallback to default coordinates if everything fails
    _fetchShops(lat: 24.860734, lon: 67.001122);
  }

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
      final radius = (CurrentUserStorage.getDiscoveryRadius() * 1000).toInt();

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

      if (response.success ||
          response.statusCode == 410 ||
          response.statusCode == 404) {
        _apiMessage = (response.statusCode == 410 || response.statusCode == 404)
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
            response.message,
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

  ShopModel _mapToShopModel(data.Shop shop) {
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
    super.close();
  }
}
