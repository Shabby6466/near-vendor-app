import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/views/screens/home/cubit/map_state.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart' as data;

class MapCubit extends Cubit<MapState> {
  final ShopServices _shopServices = ShopServices();

  MapCubit({required double lat, required double lon})
      : super(MapInitial(latitude: lat, longitude: lon)) {
    _initialize();
  }

  // Cache key: lat_lon_radius_categoryId (rounded for better hit rate)
  final Map<String, List<data.Shop>> _cache = {};

  Future<void> _initialize() async {
    try {
      final cats = await _shopServices.getCategoryNames();
      emit(MapInitial(
        latitude: state.latitude,
        longitude: state.longitude,
        radius: state.radius,
        categories: [CategoryModel.all(), ...cats],
      ));
      fetchShops();
    } catch (e) {
      fetchShops();
    }
  }

  Future<void> fetchShops({double? lat, double? lon, double? radius, CategoryModel? category}) async {
    final currentLat = lat ?? state.latitude;
    final currentLon = lon ?? state.longitude;
    final currentRadius = radius ?? state.radius;
    final currentCategory = category ?? state.selectedCategory;

    // Generate cache key (round lat/lon to 4 decimals, radius to nearest 100m)
    final cacheKey = "${currentLat.toStringAsFixed(4)}_${currentLon.toStringAsFixed(4)}_${(currentRadius / 100).round() * 100}_${currentCategory.id}";

    if (_cache.containsKey(cacheKey)) {
      emit(MapSuccess(
        latitude: currentLat,
        longitude: currentLon,
        radius: currentRadius,
        shops: _cache[cacheKey]!,
        categories: state.categories,
        selectedCategory: currentCategory,
      ));
      return;
    }

    emit(MapLoading(
      latitude: currentLat,
      longitude: currentLon,
      radius: currentRadius,
      shops: state.shops,
      categories: state.categories,
      selectedCategory: currentCategory,
    ));

    try {
      final response = await _shopServices.getShopsByMap(
        lat: currentLat,
        lon: currentLon,
        radius: currentRadius.toInt(),
        categoryId: currentCategory.id,
      );

      if (response.success) {
        // Store in cache
        _cache[cacheKey] = response.shops;

        emit(MapSuccess(
          latitude: currentLat,
          longitude: currentLon,
          radius: currentRadius,
          shops: response.shops,
          categories: state.categories,
          selectedCategory: currentCategory,
        ));
      } else {
        emit(MapFailure(
          latitude: currentLat,
          longitude: currentLon,
          radius: currentRadius,
          shops: state.shops,
          categories: state.categories,
          selectedCategory: currentCategory,
          message: response.message,
        ));
      }
    } catch (e) {
      emit(MapFailure(
        latitude: currentLat,
        longitude: currentLon,
        radius: currentRadius,
        shops: state.shops,
        categories: state.categories,
        selectedCategory: currentCategory,
        message: e.toString(),
      ));
    }
  }

  void updateRadius(double newRadius) {
    emit(MapInitial(
      latitude: state.latitude,
      longitude: state.longitude,
      radius: newRadius,
      categories: state.categories,
      selectedCategory: state.selectedCategory,
      shops: state.shops,
    ));
  }

  void selectCategory(CategoryModel category) {
    if (state.selectedCategory == category) return;
    fetchShops(category: category);
  }
}
