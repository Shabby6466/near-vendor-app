import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/shop_response.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class ShopServices {
  ShopServices();

  Future<ShopResponse> createShop(CreateShopInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.createShop, data: data);
      return ShopResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopResponse.fromJson(e.response?.data);
        } else {
          return ShopResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to create shop',
          );
        }
      }
      return ShopResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<ShopResponse> updateShop(UpdateShopInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.patch(
        '${ApiConstants.updateShopProfile}/${input.shopId}',
        data: data,
      );
      return ShopResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopResponse.fromJson(e.response?.data);
        } else {
          return ShopResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to update shop',
          );
        }
      }
      return ShopResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<GenericApiResponse> deleteShop(DeleteShopInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.delete(ApiConstants.deleteShop, data: data);
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return GenericApiResponse.fromJson(e.response?.data);
        } else {
          return GenericApiResponse(
            message: e.message ?? 'Failed to delete shop',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<ShopListResponse> getMyShops() async {
    try {
      final response = await Server.get(ApiConstants.getMyShops);
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to fetch shops',
            shops: [],
          );
        }
      }
      return ShopListResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
        shops: [],
      );
    }
  }

  Future<ShopResponse> getShopById(String id) async {
    try {
      final response = await Server.get('${ApiConstants.getShopById}$id');
      return ShopResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopResponse.fromJson(e.response?.data);
        } else {
          return ShopResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to fetch shop details',
          );
        }
      }
      return ShopResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
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
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to fetch shops for map',
            shops: [],
          );
        }
      }
      return ShopListResponse(
        success: false,
        statusCode: 500,
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
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to fetch nearby shops',
            shops: [],
          );
        }
      }
      return ShopListResponse(
        success: false,
        statusCode: 500,
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
      return ShopListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ShopListResponse.fromJson(e.response?.data);
        } else {
          return ShopListResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to search shops',
            shops: [],
          );
        }
      }
      return ShopListResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
        shops: [],
      );
    }
  }

  Future<List<CategoryModel>> getCategoryNames() async {
    try {
      final response = await Server.get(ApiConstants.getCategoriesNames);
      final dynamic data = response.data;
      
      if (data is List) {
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final listData = (data['data'] as List<dynamic>?) ?? 
                        (data['categories'] as List<dynamic>?);
        if (listData != null) {
          return listData.map((e) => CategoryModel.fromJson(e)).toList();
        }
        
        // Final fallback for map entries if not standard response
        if (!data.containsKey('success') && !data.containsKey('message')) {
          return data.entries
              .map((e) => CategoryModel(id: e.key, name: e.value.toString()))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
