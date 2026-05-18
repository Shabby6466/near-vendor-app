import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class AnalyticsServices {
  AnalyticsServices();

  Future<AnalyticsStatsResponse> getShopStats({
    required String shopId,
    int days = 7,
  }) async {
    try {
      final response = await Server.get(
        '${ApiConstants.getAnalyticsStats}$shopId',
        queryParameters: {'days': days},
      );
      if (response.data is Map<String, dynamic>) {
        return AnalyticsStatsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        return AnalyticsStatsResponse(success: false, status: 500, data: []);
      }
    } catch (e) {
      return AnalyticsStatsResponse(success: false, status: 500, data: []);
    }
  }

  Future<GenericApiResponse> sendBatchAnalytics({
    required List<String> targetIds,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "targetIds": targetIds,
        "eventType": eventType,
        "metadata": metadata ?? {},
      };

      final response = await Server.post(
        ApiConstants.batchAnalytics,
        data: data,
      );

      if (response.data is Map<String, dynamic>) {
        return GenericApiResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        return GenericApiResponse(message: 'Invalid response format');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null &&
            e.response?.data is Map<String, dynamic>) {
          return GenericApiResponse.fromJson(
            e.response?.data as Map<String, dynamic>,
          );
        } else {
          return GenericApiResponse(
            message: e.message ?? 'Failed to send analytics',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }
}
