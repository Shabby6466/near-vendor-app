import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class AnalyticsServices {
  Future<AnalyticsStatsResponse> getShopStats({
    required String shopId,
    int days = 7,
  }) async {
    try {
      final response = await Server.get(
        '${ApiConstants.getAnalyticsStats}$shopId',
        queryParameters: {'days': days},
      );
      return AnalyticsStatsResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return AnalyticsStatsResponse.fromJson(e.response?.data);
        } else {
          return AnalyticsStatsResponse(message: e.message, data: []);
        }
      }
      return AnalyticsStatsResponse(message: e.toString(), data: []);
    }
  }

  Future<GenericApiResponse> sendBatchAnalytics({
    required List<String> targetIds,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.batchAnalytics,
        data: {
          "targetIds": targetIds,
          "eventType": eventType,
          "metadata": metadata ?? {},
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return GenericApiResponse.fromJson(e.response?.data);
        } else {
          return GenericApiResponse(message: e.message);
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }
}
