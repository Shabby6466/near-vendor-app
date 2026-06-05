import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class SafetyServices {
  Future<GenericApiResponse> reportContent({
    required String targetId,
    required String targetType,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.reportContent,
        data: {
          'targetId': targetId,
          'targetType': targetType.toUpperCase(),
          'reason': reason,
          if (additionalDetails != null) 'additionalDetails': additionalDetails,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> blockUser({
    required String blockedId,
    String? reason,
  }) async {
    try {
      final response = await Server.post(
        ApiConstants.blockUser,
        data: {
          'blockedId': blockedId,
          if (reason != null) 'reason': reason,
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> unblockUser(String blockedId) async {
    try {
      final response = await Server.delete(
        '${ApiConstants.blockUser}/$blockedId',
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }
}
