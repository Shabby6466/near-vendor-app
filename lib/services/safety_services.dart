import 'package:dio/dio.dart';
import 'package:nearvendorapp/enums/report_target_type.dart';
import 'package:nearvendorapp/models/api_responses/blocked_shops_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class SafetyServices {
  Future<GenericApiResponse> reportContent({
    required String targetId,
    required ReportTargetType targetType,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.reportContent,
        data: {
          'targetId': targetId,
          'targetType': targetType.name.toUpperCase(),
          'reason': reason,
          if (additionalDetails != null) 'additionalDetails': additionalDetails,
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

  Future<GenericApiResponse> blockShop({
    required String blockedShopId,
    String? reason,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.blockShop,
        data: {'blockedShopId': blockedShopId, if (reason != null) 'reason': reason},
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

  Future<GenericApiResponse> unblockShop(String blockedShopId) async {
    try {
      final response = await Server.delete(
        '${ApiConstants.blockShop}/$blockedShopId',
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

  Future<BlockedShopsResponse> getBlockedShops() async {
    try {
      final response = await Server.get(
        ApiConstants.blockedShops,
      );
      return BlockedShopsResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return BlockedShopsResponse.fromJson(e.response?.data);
        } else {
          return BlockedShopsResponse(success: false, message: e.message, shops: []);
        }
      }
      return BlockedShopsResponse(success: false, message: e.toString(), shops: []);
    }
  }
}
