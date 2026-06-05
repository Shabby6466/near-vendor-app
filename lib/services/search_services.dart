import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/models/api_request_models/search_api_inputs.dart';
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
      return SearchItemResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return SearchItemResponse(
        success: false,
        status: 500,
        items: [],
        message: e.toString(),
      );
    }
  }

  Future<SearchItemResponse> getRecentItems() async {
    try {
      final response = await Server.get(ApiConstants.getRecentItems);
      return SearchItemResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return SearchItemResponse(
        success: false,
        status: 500,
        items: [],
        message: e.toString(),
      );
    }
  }

  Future<SearchItemResponse> visualSearch({
    required String imagePath,
    required double lat,
    required double lon,
    double radius = 100000,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint(
        'VISUAL SEARCH: radius=$radius, lat=$lat, lon=$lon, path=$imagePath',
      );
      final response = await Server.post(
        ApiConstants.visualSearch,
        data: FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        }),
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': radius,
          'page': page,
          'limit': limit,
        },
      );

      return SearchItemResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return SearchItemResponse(
        success: false,
        status: 500,
        items: [],
        message: e.toString(),
      );
    }
  }
}
