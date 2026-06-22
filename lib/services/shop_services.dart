import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/shop_response.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/categories_service.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class ShopServices {
  Future<ShopResponse> getShopById(String id) async {
    try {
      final response = await Server.get('${ApiConstants.getShopById}$id');
      return ShopResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopResponse.fromJson(e.response?.data);
        } else {
          return ShopResponse(message: e.message);
        }
      }
      return ShopResponse(message: e.toString());
    }
  }

  Future<ShopListResponse> getShopsByMap({
    required double lat,
    required double lon,
    required int radius,
    String? categoryId,
    double? minLat,
    double? maxLat,
    double? minLon,
    double? maxLon,
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'lat': lat,
        'lon': lon,
        'radius': radius,
        'page': page,
        'limit': limit,
        if (categoryId != null && categoryId != 'all') 'categoryId': categoryId,
        if (minLat != null) 'minLat': minLat,
        if (maxLat != null) 'maxLat': maxLat,
        if (minLon != null) 'minLon': minLon,
        if (maxLon != null) 'maxLon': maxLon,
      };

      final response = await Server.get(
        ApiConstants.getShopsByMap,
        queryParameters: params,
      );
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(message: e.message, shops: []);
        }
      }
      return ShopListResponse(message: e.toString(), shops: []);
    }
  }

  Future<ShopListResponse> getNearbyShops({
    required double lat,
    required double lon,
    String? categoryId,
    int radius = 10000,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'lat': lat,
        'lon': lon,
        'radius': radius,
        'page': page,
        'limit': limit,
        if (categoryId != null && categoryId != 'all') 'categoryId': categoryId,
      };

      final response = await Server.get(
        ApiConstants.getNearbyShops,
        queryParameters: params,
      );
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(message: e.message, shops: []);
        }
      }
      return ShopListResponse(message: e.toString(), shops: []);
    }
  }

  Future<ShopListResponse> searchShops({
    required double lat,
    required double lon,
    required String query,
    int radius = 10000,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await Server.get(
        ApiConstants.searchShops,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': radius,
          'query': query,
          'page': page,
          'limit': limit,
        },
      );
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(message: e.message, shops: []);
        }
      }
      return ShopListResponse(message: e.toString(), shops: []);
    }
  }

  Future<List<CategoryModel>> getCategoryNames() async {
    return (await CategoriesService.getCategories()).categories;
  }
}
