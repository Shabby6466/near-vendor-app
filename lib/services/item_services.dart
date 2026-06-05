import 'package:nearvendorapp/models/api_request_models/item_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/item_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class ItemServices {
  Future<ItemResponse> createItem(CreateItemInput input) async {
    try {
      final response = await Server.post(
        ApiConstants.createItem,
        data: input.toJson(),
      );
      return ItemResponse.fromJson(response.data);
    } catch (e) {
      return ItemResponse(success: false, status: 500, message: e.toString());
    }
  }

  Future<ItemResponse> updateItem(UpdateItemInput input) async {
    try {
      final response = await Server.put(
        '${ApiConstants.updateItem}${input.id}',
        data: input.toJson(),
      );
      return ItemResponse.fromJson(response.data);
    } catch (e) {
      return ItemResponse(success: false, status: 500, message: e.toString());
    }
  }

  Future<GenericApiResponse> deleteItem(String id) async {
    try {
      final response = await Server.delete('${ApiConstants.deleteItem}$id');
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<ItemListResponse> getItemsByShopId(String shopId) async {
    try {
      final response = await Server.get(
        ApiConstants.getItemsByShop,
        queryParameters: {'shopId': shopId},
      );
      return ItemListResponse.fromJson(response.data);
    } catch (e) {
      return ItemListResponse(
        success: false,
        status: 500,
        message: e.toString(),
        items: [],
      );
    }
  }

  Future<ItemResponse> getItemById(String id) async {
    try {
      final response = await Server.get('${ApiConstants.getItemById}/$id');
      return ItemResponse.fromJson(response.data);
    } catch (e) {
      return ItemResponse(success: false, status: 500, message: e.toString());
    }
  }
}
