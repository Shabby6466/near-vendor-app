import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/search_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class SearchServices {
  SearchServices();

  Future<SearchItemResponse> searchItems(SearchItemInput input) async {
    try {
      final response = await Server.get(
        ApiConstants.searchItems,
        queryParameters: input.toJson(),
      );
      return SearchItemResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return SearchItemResponse.fromJson(e.response!.data);
        }
        return SearchItemResponse(
          success: false,
          statusCode: e.response?.statusCode ?? 500,
          items: [],
          message: e.message,
        );
      }
      return SearchItemResponse(
        success: false,
        statusCode: 500,
        items: [],
        message: e.toString(),
      );
    }
  }

  Future<SearchItemResponse> getRecentItems() async {
    try {
      final response = await Server.get(ApiConstants.getRecentItems);
      // Even though it's recent items, we can use SearchItemResponse.fromJson 
      // if the structure matches {success, data: [items...]}
      return SearchItemResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return SearchItemResponse.fromJson(e.response!.data);
        }
        return SearchItemResponse(
          success: false,
          statusCode: e.response?.statusCode ?? 500,
          items: [],
          message: e.message,
        );
      }
      return SearchItemResponse(
        success: false,
        statusCode: 500,
        items: [],
        message: e.toString(),
      );
    }
  }
}
