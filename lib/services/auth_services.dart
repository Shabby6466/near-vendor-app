import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/auth_api_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

class AuthServices {
  AuthServices();
  Future<GenericApiResponse> createUser(CreateUserInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();

      final response = await Server.post(ApiConstants.createUser, data: data);
      print('response inside $response');
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

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.verifyOTP, data: data);
      return VerifyOtpResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return VerifyOtpResponse.fromJson(e.response?.data);
        } else {
          return VerifyOtpResponse(message: e.message);
        }
      }
      return VerifyOtpResponse(message: e.toString());
    }
  }

  Future<LoginResponse> login(LoginInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.login, data: data);

      return LoginResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return LoginResponse.fromJson(e.response?.data);
        } else {
          return LoginResponse(message: e.message);
        }
      }
      return LoginResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> changePassword(ChangePasswordInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      debugPrint(
        'ChangePassword Token: ${CurrentUserStorage.getUserAuthToken()}',
      );
      final response = await Server.post(
        ApiConstants.changePassword,
        data: data,
      );
      print('response inside-> $response');
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

  Future<GenericApiResponse> registerVendor(RegisterInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      debugPrint('Register Token: ${CurrentUserStorage.getUserAuthToken()}');
      final response = await Server.post(
        ApiConstants.registerVendor,
        data: data,
      );
      print('response inside-> $response');
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

  Future<MeResponse> getMe() async {
    try {
      final response = await Server.get(ApiConstants.getMe);
      return MeResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return MeResponse.fromJson(e.response?.data);
        } else {
          return MeResponse(message: e.message);
        }
      }
      return MeResponse(message: e.toString());
    }
  }
}
  // Future<GenericApiResponse> refreshToken() async {
  //   try {
  //     final refreshToken = CurrentUserStorage.getUserRefreshAuthToken();
  //     if (refreshToken == null) {
  //       return GenericApiResponse(message: AppStrings.noRefreshTokenFound);
  //     }
  //
  //     final response = await Server.get(
  //       ApiConstants.refreshToken,
  //       headers: {
  //         'Authorization': 'Bearer $refreshToken',
  //       },
  //     );
  //
  //     final data = response.data;
  //     if (data is Map) {
  //       final String? newAccessToken = data['token'] as String?;
  //       final String? newRefreshToken = data['refreshToken'] as String?;
  //       if (newAccessToken != null) {
  //         await CurrentUserStorage.storeUserAuthToken(
  //           newAccessToken,
  //           newRefreshToken,
  //         );
  //       }
  //     }
  //     return GenericApiResponse.fromJson(response.data);
  //   } catch (e) {
  //     if (e is DioException) {
  //       if (e.response?.data != null) {
  //         return GenericApiResponse.fromJson(e.response?.data);
  //       } else {
  //         return GenericApiResponse(message: e.message);
  //       }
  //     }
  //     return GenericApiResponse(message: e.toString());
  //   }
  // }
