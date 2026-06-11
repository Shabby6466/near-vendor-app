import 'package:nearvendorapp/models/api_responses/base_api_response.dart';

class ForgotPasswordResponse extends BaseApiResponse {
  ForgotPasswordResponse({super.message, super.status});

  ForgotPasswordResponse.fromJson(dynamic json) : super.fromJson(json);
}

class VerifyResetOtpResponse extends BaseApiResponse {
  String? resetToken;

  VerifyResetOtpResponse({super.message, super.status, this.resetToken});

  VerifyResetOtpResponse.fromJson(dynamic json) : super.fromJson(json) {
    final data = apiResponseDataMap(json);
    resetToken = data?['resetToken'] as String?;
  }

  @override
  bool get isSuccess => resetToken != null;
}

class ResetPasswordResponse extends BaseApiResponse {
  ResetPasswordResponse({super.message, super.status});

  ResetPasswordResponse.fromJson(dynamic json) : super.fromJson(json);
}
