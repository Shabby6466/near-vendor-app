import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/analytics_response.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';
import 'package:nearvendorapp/services/server.dart';

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
      return AnalyticsStatsResponse.fromJson(response.data);
    } catch (e) {
      return AnalyticsStatsResponse(success: false, statusCode: 500, data: []);
    }
  }

  Future<PortfolioAnalyticsResponse> getVendorPortfolio({int days = 7}) async {
    try {
      final response = await Server.get(
        ApiConstants.getVendorPortfolioAnalytics,
        queryParameters: {'days': days},
      );
      return PortfolioAnalyticsResponse.fromJson(response.data);
    } catch (e) {
      return PortfolioAnalyticsResponse(success: false, statusCode: 500, data: []);
    }
  }

  Future<ShopInsightsResponse> getVendorShopInsights({
    required String shopId,
    int days = 7,
  }) async {
    try {
      final response = await Server.get(
        '${ApiConstants.getVendorShopAnalytics}$shopId',
        queryParameters: {'days': days},
      );
      return ShopInsightsResponse.fromJson(response.data);
    } catch (e) {
      return ShopInsightsResponse(
        success: false,
        statusCode: 500,
        data: ShopInsightsData(
          summary: InsightsSummary(impressions: 0, views: 0, ctr: 0),
          topKeywords: [],
          historical: [],
        ),
      );
    }
  }

  Future<MarketInsightsResponse> getMarketInsights({
    required String shopId,
    int days = 7,
    int radius = 15000,
  }) async {
    try {
      final response = await Server.get(
        '${ApiConstants.getVendorShopAnalytics}$shopId${ApiConstants.getMarketInsightsSuffix}',
        queryParameters: {'days': days, 'radius': radius},
      );
      return MarketInsightsResponse.fromJson(response.data);
    } catch (e) {
      return MarketInsightsResponse(
        success: false,
        statusCode: 500,
        data: MarketInsightsData(
          neighborhoodDemand: [],
          unmetDemand: [],
          radiusMeters: radius.toDouble(),
        ),
      );
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
      
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return GenericApiResponse.fromJson(e.response?.data);
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
