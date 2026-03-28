import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/shop_response.dart';
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
}
