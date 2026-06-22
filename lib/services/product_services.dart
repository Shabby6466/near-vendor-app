import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/product_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class ProductServices {
  Future<ProductListResponse> getProductsByShopId(String shopId) async {
    try {
      final response = await Server.get(
        ApiConstants.getItemsByShop,
        queryParameters: {'shopId': shopId},
      );
      return ProductListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ProductListResponse.fromJson(e.response?.data);
        } else {
          return ProductListResponse(message: e.message, items: []);
        }
      }
      return ProductListResponse(message: e.toString(), items: []);
    }
  }

  Future<ProductResponse> getProductById(String id) async {
    try {
      final response = await Server.get('${ApiConstants.getItemById}/$id');
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ProductResponse.fromJson(e.response?.data);
        } else {
          return ProductResponse(message: e.message);
        }
      }
      return ProductResponse(message: e.toString());
    }
  }
}
