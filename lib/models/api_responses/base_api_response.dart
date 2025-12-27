import 'package:dio/dio.dart';

abstract class BaseApiResponse {
  int? _status;
  String? _message;

  int? get status => _status;
  String? get message => _message;

  BaseApiResponse({
    int? status,
    String? message,
  }) {
    _status = status;
    _message = message;
  }

  BaseApiResponse.fromJson(dynamic json) {
    if (json is Map) {
      _paseData(json);
    } else if (json is Response) {
      if (json.data is Map) {
        _paseData(json.data as Map);
      } else {
        _message = json.data.toString();
      }
      _status = json.statusCode;
    }
  }

  void _paseData(Map json) {
    _status = json["statusCode"] as int?;
    _message = json["message"] as String?;
    if (_message == null && json.keys.contains('errors')) {
      if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
        _message = (json['errors'] as List).first is Map
            ? ((json['errors'] as List).first as Map).values.first?.toString()
            : (json['errors'] as List).first.toString();
      } else {
        _message = json['errors'].toString();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["status"] = _status;
    map["message"] = _message;
    return map;
  }
}
