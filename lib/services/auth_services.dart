import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/auth_api_response.dart';
import 'package:nearvendorapp/models/api_responses/forgot_password_response.dart';
import 'package:nearvendorapp/models/api_responses/media_upload_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class AuthServices {
  Future<LoginResponse> createUser(CreateUserInput input) async {
    try {
      final response = await Server.post(
        ApiConstants.createUser,
        data: input.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      return LoginResponse(message: e.toString());
    }
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpInput input) async {
    try {
      final response = await Server.post(
        ApiConstants.verifyOTP,
        data: input.toJson(),
      );
      return VerifyOtpResponse.fromJson(response.data);
    } catch (e) {
      return VerifyOtpResponse(message: e.toString());
    }
  }

  Future<LoginResponse> login(LoginInput input) async {
    try {
      final response = await Server.post(
        ApiConstants.login,
        data: input.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      return LoginResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> changePassword(ChangePasswordInput input) async {
    try {
      final response = await Server.post(
        ApiConstants.changePassword,
        data: input.toJson(),
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<MeResponse> getMe() async {
    try {
      final response = await Server.get(ApiConstants.getMe);
      return MeResponse.fromJson(response.data);
    } catch (e) {
      return MeResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> updateUser(UpdateUserInput input) async {
    try {
      final response = await Server.patch(
        ApiConstants.updateUser,
        data: input.toJson(),
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> deleteAccount(String password) async {
    try {
      final response = await Server.delete(
        ApiConstants.deleteAccount,
        data: {'password': password},
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<MediaUploadResponse> uploadMedia(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await Server.post(
        ApiConstants.uploadMedia,
        data: formData,
      );
      return MediaUploadResponse.fromJson(response.data);
    } catch (e) {
      return MediaUploadResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> updateUserLocation(double lat, double lon) async {
    try {
      final response = await Server.post(
        ApiConstants.updateUserLocation,
        data: {
          'latitude': double.parse(lat.toStringAsFixed(7)),
          'longitude': double.parse(lon.toStringAsFixed(7)),
        },
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    try {
      final response = await Server.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return ForgotPasswordResponse.fromJson(response.data);
    } catch (e) {
      return ForgotPasswordResponse(message: e.toString());
    }
  }

  Future<VerifyResetOtpResponse> verifyResetOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await Server.post(
        ApiConstants.verifyResetOtp,
        data: {'email': email, 'otp': otp},
      );
      return VerifyResetOtpResponse.fromJson(response.data);
    } catch (e) {
      return VerifyResetOtpResponse(message: e.toString());
    }
  }

  Future<ResetPasswordResponse> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    try {
      final response = await Server.post(
        ApiConstants.resetPassword,
        data: {'newPassword': newPassword},
        headers: {'Authorization': 'Bearer $resetToken'},
      );
      return ResetPasswordResponse.fromJson(response.data);
    } catch (e) {
      return ResetPasswordResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> updateNotificationToken(String fcmToken) async {
    try {
      final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
      final response = await Server.post(
        ApiConstants.deviceToken,
        data: {'deviceToken': fcmToken, 'deviceType': deviceType},
      );
      return GenericApiResponse.fromJson(response.data);
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }

  Future<GenericApiResponse> deleteNotificationToken() async {
    try {
      final currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken != null) {
        final response = await Server.delete(
          ApiConstants.deviceToken,
          data: {'deviceToken': currentToken},
        );
        return GenericApiResponse.fromJson(response.data);
      }
      return GenericApiResponse(message: 'No token to remove');
    } catch (e) {
      return GenericApiResponse(message: e.toString());
    }
  }
}
