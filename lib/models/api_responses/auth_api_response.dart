import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/user.dart';

class AuthApiResponse extends BaseApiResponse {
  Data? _data;

  Data? get data => _data;

  AuthApiResponse({
    super.message,
    Data? data,
  }) {
    _data = data;
  }

  AuthApiResponse.fromJson(dynamic json) : super.fromJson(json) {
    if (json is Map) {
      _data = json["data"] != null ? Data.fromJson(json["data"]) : null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = super.toJson();
    map["data"] = _data?.toJson();
    return map;
  }
}

class Data {
  User? _user;
  String? _refreshToken;
  String? _accessToken;

  User? get user => _user;
  String? get refreshToken => _refreshToken;
  String? get accessToken => _accessToken;

  Data({
    User? user,
    String? accessToken,
    String? refreshToken,
  }) {
    _user = user;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Data.fromJson(dynamic json) {
    if (json is Map) {
      _user = json["user"] != null ? User.fromJson(json["user"]) : null;
      _accessToken = json["token"] as String?;
      _refreshToken = json["refreshToken"] as String?;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["user"] = _user?.toJson();
    map["token"] = _accessToken;
    map["refreshToken"] = _refreshToken;
    return map;
  }
}
