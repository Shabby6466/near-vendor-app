import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/user.dart';

class VerifyOtpResponse extends BaseApiResponse {
  String? token;
  String? refreshToken;
  User? user;
  bool? mustChangePassword;

  VerifyOtpResponse({
    super.message,
    super.status,
    this.token,
    this.refreshToken,
    this.user,
    this.mustChangePassword,
  });

  VerifyOtpResponse.fromJson(dynamic json) : super.fromJson(json) {
    final data = apiResponseDataMap(json);
    token = data?["token"] as String?;
    refreshToken = data?["refreshToken"] as String?;
    mustChangePassword = data?["mustChangePassword"] as bool?;
    user = data?["user"] != null ? User.fromJson(data!["user"]) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = super.toJson();
    map["token"] = token;
    map["refreshToken"] = refreshToken;
    map["mustChangePassword"] = mustChangePassword;
    map["user"] = user?.toJson();
    return map;
  }
}

class LoginResponse extends BaseApiResponse {
  String? token;
  String? refreshToken;
  User? user;

  LoginResponse({
    super.message,
    super.status,
    this.token,
    this.refreshToken,
    this.user,
  });

  LoginResponse.fromJson(dynamic json) : super.fromJson(json) {
    final data = apiResponseDataMap(json);
    token = data?["token"] as String?;
    refreshToken = data?["refreshToken"] as String?;
    user = data?["user"] != null ? User.fromJson(data!["user"]) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = super.toJson();
    map["token"] = token;
    map["refreshToken"] = refreshToken;
    map["user"] = user?.toJson();
    return map;
  }
}

class MeResponse extends BaseApiResponse {
  User? user;

  MeResponse({super.message, super.status, this.user});

  MeResponse.fromJson(dynamic json) : super.fromJson(json) {
    final data = apiResponseDataMap(json);
    user = data != null ? User.fromJson(data) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = super.toJson();
    map["user"] = user?.toJson();
    return map;
  }
}
