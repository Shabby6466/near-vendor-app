import 'package:dio/dio.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class SafetyServices {
  SafetyServices();

  Future<GenericApiResponse> reportContent({
    required String targetId,
    required String targetType,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'targetId': targetId,
        'targetType': targetType.toUpperCase(),
        'reason': reason,
        if (additionalDetails != null) 'additionalDetails': additionalDetails,
      };

      final response = await Server.post(
        ApiConstants.reportContent,
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
            message: e.message ?? 'Failed to submit report',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> blockUser({
    required String blockedId,
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'blockedId': blockedId,
        if (reason != null) 'reason': reason,
      };

      final response = await Server.post(ApiConstants.blockUser, data: data);
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
            message: e.message ?? 'Failed to block user',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> unblockUser(String blockedId) async {
    try {
      final response = await Server.delete(
        '${ApiConstants.blockUser}/$blockedId',
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
            message: e.message ?? 'Failed to unblock user',
          );
        }
      }
      return GenericApiResponse(message: e.toString());
    }
  }
}
