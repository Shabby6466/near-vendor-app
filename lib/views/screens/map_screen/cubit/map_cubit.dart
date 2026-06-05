import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/models/data_models/shop.dart' as data;
import 'package:nearvendorapp/services/shop_services.dart';
import 'package:nearvendorapp/views/screens/map_screen/cubit/map_state.dart';

class MapCubit extends Cubit<MapState> {
  final ShopServices _shopServices = ShopServices();

  double latitude;
  double longitude;
  double radius = 5000;
  List<data.Shop> shops = const [];
  List<CategoryModel> categories = const [];
  CategoryModel selectedCategory = CategoryModel.all();
  String errorMessage = '';

  MapCubit({required double lat, required double lon})
      : latitude = lat,
        longitude = lon,
        super(MapInitial()) {
    _initialize();
  }

  // Cache key: lat_lon_bounds_categoryId
  final Map<String, List<data.Shop>> _cache = {};

  Future<void> _initialize() async {
    try {
      final cats = await _shopServices.getCategoryNames();
      categories = [CategoryModel.all(), ...cats];
      emit(MapInitial());
      fetchShops();
    } catch (e) {
      fetchShops();
    }
  }

  Future<void> fetchShops({
    double? lat,
    double? lon,
    double? radius,
    CategoryModel? category,
    double? minLat,
    double? maxLat,
    double? minLon,
    double? maxLon,
  }) async {
    if (lat != null) latitude = lat;
    if (lon != null) longitude = lon;
    if (radius != null) this.radius = radius;
    if (category != null) selectedCategory = category;

    // Generate cache key
    String cacheKey;
    if (minLat != null && maxLat != null && minLon != null && maxLon != null) {
      cacheKey = "bounds_${minLat.toStringAsFixed(3)}_${maxLat.toStringAsFixed(3)}_${minLon.toStringAsFixed(3)}_${maxLon.toStringAsFixed(3)}_${selectedCategory.id}";
    } else {
      cacheKey = "radius_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}_${(this.radius / 100).round() * 100}_${selectedCategory.id}";
    }

    if (_cache.containsKey(cacheKey)) {
      shops = _cache[cacheKey]!;
      errorMessage = '';
      emit(MapSuccess());
      return;
    }

    errorMessage = '';
    emit(MapLoading());

    try {
      final response = await _shopServices.getShopsByMap(
        lat: latitude,
        lon: longitude,
        radius: this.radius.toInt(),
        categoryId: selectedCategory.id,
        minLat: minLat,
        maxLat: maxLat,
        minLon: minLon,
        maxLon: maxLon,
      );

      if (response.isSuccess) {
        shops = response.shops;
        _cache[cacheKey] = response.shops;
        emit(MapSuccess());
      } else {
        errorMessage = response.message ?? 'Failed to fetch shops';
        emit(MapFailure(errorMessage));
      }
    } catch (e) {
      errorMessage = e.toString();
      emit(MapFailure(errorMessage));
    }
  }

  void updateRadius(double newRadius) {
    radius = newRadius;
    emit(MapInitial());
  }

  void selectCategory(CategoryModel category) {
    if (selectedCategory == category) return;
    fetchShops(category: category);
  }
}
