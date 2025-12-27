import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_responses/auth_api_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

class AuthServices {
  Future<GenericApiResponse> sendOtp({
    required String email,
  }) async {
    try {
      final Map data = {
        'email': email.trim().toLowerCase(),
      };

      final response = await Server.post(
        ApiConstants.sendOTP,
        data: data,
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

  Future<AuthApiResponse> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final Map data = {
        "email": email,
        "code": otp,
      };

      final response = await Server.post(
        ApiConstants.verifyOTP,
        data: data,
      );

      return AuthApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return AuthApiResponse.fromJson(e.response);
        } else {
          return AuthApiResponse(message: e.message);
        }
      }
      return AuthApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> setPassword(String password) async {
    try {
      final token = CurrentUserStorage.getUserAuthToken();
      final Map data = {
        'password': password,
        'token': token,
      };
      final response = await Server.post(
        ApiConstants.setPassword,
        data: data,
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

  Future<AuthApiResponse> login(
    String email,
    String password,
  ) async {
    try {
      final Map data = {
        "email": email,
        "password": password,
      };

      final response = await Server.post(
        ApiConstants.login,
        data: data,
      );
      return AuthApiResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          return AuthApiResponse.fromJson(e.response);
        } else {
          return AuthApiResponse(message: e.message);
        }
      }
      return AuthApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> forgotPassword(String email) async {
    try {
      final Map data = {
        "email": email,
      };
      final response = await Server.post(
        ApiConstants.forgotPassword,
        data: data,
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

  Future<GenericApiResponse> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final Map data = {
        "oldPassword": oldPassword,
        "password": newPassword,
      };
      final response = await Server.patch(
        ApiConstants.password,
        data: data,
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

  Future<GenericApiResponse> refreshToken() async {
    try {
      final refreshToken = CurrentUserStorage.getUserRefreshAuthToken();
      if (refreshToken == null) {
        return GenericApiResponse(message: AppStrings.noRefreshTokenFound);
      }

      final response = await Server.get(
        ApiConstants.refreshToken,
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      );

      final data = response.data;
      if (data is Map) {
        final String? newAccessToken = data['token'] as String?;
        final String? newRefreshToken = data['refreshToken'] as String?;
        if (newAccessToken != null) {
          await CurrentUserStorage.storeUserAuthToken(
            newAccessToken,
            newRefreshToken,
          );
        }
      }
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

  Future<GenericApiResponse> deleteUser() async {
    try {
      final response = await Server.delete(
        ApiConstants.user,
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
