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

  VerifyOtpResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    token = json["token"] as String?;
    refreshToken = json["refreshToken"] as String?;
    mustChangePassword = json["mustChangePassword"] as bool?;
    user = json["user"] != null ? User.fromJson(json["user"]) : null;
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

  LoginResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    token = json["token"] as String?;
    refreshToken = json["refreshToken"] as String?;
    user = json["user"] != null ? User.fromJson(json["user"]) : null;
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

  // NOTE: The backend returns user fields at the root level of GET /users/me
  // (not nested under a 'user' or 'data' key), so we parse from the root json.
  // If the backend is updated to return { user: {...} }, update this constructor.
  MeResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    user = User.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = super.toJson();
    map["user"] = user?.toJson();
    return map;
  }
}
