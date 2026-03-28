import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/shop_api_inputs.dart';
import 'package:nearvendorapp/models/api_inputs/vendor_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/shop_api_responses.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class VendorServices {
  Future<GenericApiResponse> vendorUpdate(UpdateVendorInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.patch(
        ApiConstants.updateVendor,
        data: data,
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<GenericApiResponse> createShop(CreateShopInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.createShop, data: data);
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<GenericApiResponse> deleteShop(DeleteShopInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.delete(ApiConstants.deleteShop, data: data);
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<List<GetMyShopInventoryResponse>> getMyShops() async {
    try {
      final response = await Server.get(ApiConstants.getMyShops);
      if (response.data is List) {
        return (response.data as List)
            .map(
              (e) => GetMyShopInventoryResponse.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      } else if (response.data is Map && response.data['shops'] is List) {
        return (response.data['shops'] as List)
            .map(
              (e) => GetMyShopInventoryResponse.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  GenericApiResponse _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        return GenericApiResponse.fromJson(e.response?.data);
      } else {
        return GenericApiResponse(message: e.message);
      }
    }
    return GenericApiResponse(message: e.toString());
  }
}
