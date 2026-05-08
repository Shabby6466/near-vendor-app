import 'package:dio/dio.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/models/api_responses/auth_api_response.dart';
import 'package:nearvendorapp/models/api_responses/media_upload_response.dart';
import 'package:nearvendorapp/services/server.dart';
import 'package:nearvendorapp/utils/constants/api_constants.dart';
import 'package:nearvendorapp/utils/generic_api_response.dart';

class AuthServices {
  AuthServices();

  Future<LoginResponse> createUser(CreateUserInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.post(ApiConstants.createUser, data: data);
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
      final response = await Server.post(
        ApiConstants.changePassword,
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

  Future<GenericApiResponse> updateUser(UpdateUserInput input) async {
    try {
      final Map<String, dynamic> data = input.toJson();
      final response = await Server.patch(ApiConstants.updateUser, data: data);
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

  Future<GenericApiResponse> deleteAccount(String password) async {
    try {
      final response = await Server.delete(
        ApiConstants.deleteAccount,
        data: {'password': password},
      );
      // Backend returns { success: true, message: "..." } with no statusCode field.
      // Use the HTTP status code directly from the Dio response.
      return GenericApiResponse(
        status: response.statusCode,
        message: response.data is Map
            ? (response.data as Map<String, dynamic>)['message'] as String?
            : null,
      );
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
      if (e is DioException) {
        if (e.response?.data != null) {
          return MediaUploadResponse.fromJson(e.response?.data);
        } else {
          return MediaUploadResponse(message: e.message);
        }
      }
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
