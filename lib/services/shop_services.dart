import 'package:nearvendorapp/models/api_responses/shop_response.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/categories_service.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class ShopServices {
  ShopServices();

  Future<ShopResponse> getShopById(String id) async {
    try {
      final response = await Server.get('${ApiConstants.getShopById}$id');
      return ShopResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ShopResponse(success: false, status: 500, message: e.toString());
    }
  }

  Future<ShopListResponse> getShopsByMap({
    required double lat,
    required double lon,
    required int radius,
    String? categoryId,
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'lat': double.parse(lat.toStringAsFixed(7)),
        'lon': double.parse(lon.toStringAsFixed(7)),
        'radius': radius,
        'page': page,
        'limit': limit,
      };

      if (categoryId != null && categoryId != 'all') {
        params['categoryId'] = categoryId;
      }

      final response = await Server.get(
        ApiConstants.getShopsByMap,
        queryParameters: params,
      );
      return ShopListResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ShopListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        shops: [],
      );
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
        'lat': double.parse(lat.toStringAsFixed(7)),
        'lon': double.parse(lon.toStringAsFixed(7)),
        'radius': radius,
        'page': page,
        'limit': limit,
      };
      if (categoryId != null && categoryId != 'all') {
        params['categoryId'] = categoryId;
      }

      final response = await Server.get(
        ApiConstants.getNearbyShops,
        queryParameters: params,
      );
      return ShopListResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ShopListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        shops: [],
      );
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
      final Map<String, dynamic> params = {
        'lat': double.parse(lat.toStringAsFixed(7)),
        'lon': double.parse(lon.toStringAsFixed(7)),
        'radius': radius,
        'query': query,
        'page': page,
        'limit': limit,
      };

      final response = await Server.get(
        ApiConstants.searchShops,
        queryParameters: params,
      );
      return ShopListResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ShopListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        shops: [],
      );
    }
  }

  Future<List<CategoryModel>> getCategoryNames() async {
    return (await CategoriesService.getCategories()).categories;
  }
}
