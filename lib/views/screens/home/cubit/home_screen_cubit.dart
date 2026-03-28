import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';
import 'package:nearvendorapp/models/ui_models/categories_list.dart';
import 'package:nearvendorapp/models/ui_models/shop_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final ShopServices _shopServices = ShopServices();

  HomeScreenCubit() : super(HomeScreenInitial()) {
    _initialize();
  }

  // Variables stored in the Cubit, as requested
  List<ShopModel> _allShops = [];
  String _selectedCategory = CategoriesList.All;
  String? _apiMessage;

  // Public getters if needed by widgets outside BlocBuilder
  String get selectedCategory => _selectedCategory;
  List<ShopModel> get filteredShops => _getFilteredShops();

  Future<void> _initialize() async {
    await loadShops();
  }

  Future<void> loadShops() async {
    emit(HomeScreenLoading());

    try {
      // Get current location
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback to default coordinates if location service is disabled
        return _fetchShops(lat: 24.860734, lon: 67.001122);
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Fallback to default coordinates if permission is denied
          return _fetchShops(lat: 24.860734, lon: 67.001122);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Fallback to default coordinates if permission is denied forever
        return _fetchShops(lat: 24.860734, lon: 67.001122);
      }

      final position = await Geolocator.getCurrentPosition();
      await _fetchShops(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      emit(HomeScreenFailure(e.toString()));
    }
  }

  Future<void> _fetchShops({required double lat, required double lon}) async {
    try {
      final response = await _shopServices.getNearbyShops(lat: lat, lon: lon);
      
      if (response.success || response.statusCode == 410) {
        _apiMessage = response.statusCode == 410 ? response.message : null;
        _allShops = response.shops.map((shop) => _mapToShopModel(shop)).toList();
        
        emit(
          HomeScreenSuccess(
            shops: _getFilteredShops(),
            category: _selectedCategory,
            message: _apiMessage,
          ),
        );
      } else {
        emit(HomeScreenFailure(response.message));
      }
    } catch (e) {
      emit(HomeScreenFailure(e.toString()));
    }
  }

  ShopModel _mapToShopModel(Shop shop) {
    return ShopModel(
      id: shop.id,
      name: shop.shopName,
      image: shop.coverImageUrl ?? '',
      category: shop.businessCategory,
      latitude: shop.shopLatitude,
      longitude: shop.shopLongitude,
      location: shop.shopAddress,
      itemCount: shop.itemCount,
      isVerifiedBadge: shop.isVerifiedBadge,
      isRecentlyActive: shop.isRecentlyActive,
    );
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;

    emit(
      HomeScreenSuccess(
        shops: _getFilteredShops(),
        category: _selectedCategory,
        message: _apiMessage,
      ),
    );
  }

  List<ShopModel> _getFilteredShops() {
    return _selectedCategory == CategoriesList.All
        ? List.from(_allShops)
        : _allShops
              .where((shop) => shop.category == _selectedCategory)
              .toList();
  }

  @override
  Future<void> close() async {
    // Clean up any listeners or subscriptions here if added later
    await super.close();
  }
}
