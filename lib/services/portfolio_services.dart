import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/portfolio_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';

class PortfolioServices {
  PortfolioServices();

  Future<PortfolioSearchResponse> searchPortfolio({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await Server.get(
        ApiConstants.searchPortfolio,
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );
      return PortfolioSearchResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        return PortfolioSearchResponse.fromJson(e.response?.data);
      }
      return PortfolioSearchResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
        shops: [],
        items: [],
      );
    }
  }

  Future<PortfolioPerformanceResponse> getPerformance({int days = 7}) async {
    try {
      final response = await Server.get(
        ApiConstants.getPortfolioPerformance,
        queryParameters: {'days': days},
      );
      return PortfolioPerformanceResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        return PortfolioPerformanceResponse.fromJson(e.response?.data);
      }
      return PortfolioPerformanceResponse(
        success: false,
        statusCode: 500,
        message: e.toString(),
        bestPerformers: [],
        poorPerformers: [],
      );
    }
  }
}
