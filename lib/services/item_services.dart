import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/item_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/item_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class ItemServices {
  ItemServices();

  Future<ItemResponse> createItem(CreateItemInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.createItem, data: data);
      return ItemResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ItemResponse.fromJson(e.response?.data);
        } else {
          return ItemResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to create item',
          );
        }
      }
      return ItemResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<ItemResponse> updateItem(UpdateItemInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.put(
        '${ApiConstants.updateItem}${input.id}',
        data: data,
      );
      return ItemResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ItemResponse.fromJson(e.response?.data);
        } else {
          return ItemResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to update item',
          );
        }
      }
      return ItemResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<GenericApiResponse> deleteItem(String id) async {
    try {
      final response = await Server.delete('${ApiConstants.deleteItem}$id');
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return GenericApiResponse.fromJson(e.response?.data);
        } else {
          return GenericApiResponse(
            message: e.message ?? 'Failed to delete item',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<ItemListResponse> getItemsByShopId(String shopId) async {
    try {
      final response = await Server.get(
        '${ApiConstants.getItemsByShop}/$shopId',
      );
      return ItemListResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return ItemListResponse.fromJson(e.response?.data);
        } else {
          return ItemListResponse(
            success: false,
            statusCode: e.response?.statusCode ?? 500,
            message: e.message ?? 'Failed to fetch items',
            items: [],
          );
        }
      }
      return ItemListResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
        items: [],
      );
    }
  }
}
