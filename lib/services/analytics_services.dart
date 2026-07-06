import 'package:dio/dio.dart';
import 'package:nearvendorapp/analytics/analytics_event.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

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

  /// Posts a batch of buffered events to the backend.
  ///
  /// Events are grouped by type and sent as separate batch requests
  /// to match the `POST /analytics/batch` endpoint format.
  Future<void> trackBatch(List<BuyerEventData> events) async {
    if (events.isEmpty) return;

    // Group targetIds by event type
    final grouped = <String, List<String>>{};
    for (final e in events) {
      grouped.putIfAbsent(e.event.backendValue, () => []).add(e.targetId);
    }

    // One POST per event type (backend batch endpoint accepts one type at a time)
    for (final entry in grouped.entries) {
      await Server.post(
        ApiConstants.batchAnalytics,
        data: {
          'eventType': entry.key,
          'targetIds': entry.value,
        },
      );
    }
  }
}
