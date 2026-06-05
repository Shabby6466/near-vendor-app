class BaseApiResponse {
  final bool? success;
  final int? status;
  final String? message;

  BaseApiResponse({this.success, this.status, this.message});

  bool get isSuccess => success ?? (status != null && status! >= 200 && status! < 300);

  BaseApiResponse.fromJson(dynamic json)
    : success = json is Map
          ? (json['success'] is bool
              ? json['success'] as bool
              : json['statusCode'] != null
              ? (json['statusCode'] as num).toInt() >= 200 &&
                    (json['statusCode'] as num).toInt() < 300
              : null)
          : null,
      status = json is Map ? (json['statusCode'] as num?)?.toInt() : null,
      message = json is Map ? json['message'] as String? : null;

  Map<String, dynamic> toJson() {
    return {'success': success, 'statusCode': status, 'message': message};
  }
}

dynamic apiResponseData(dynamic json) {
  if (json is Map && json.containsKey('data')) {
    return json['data'];
  }
  return json;
}

Map<String, dynamic>? apiResponseDataMap(dynamic json) {
  final data = apiResponseData(json);
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return data.cast<String, dynamic>();
  return null;
}

List<dynamic> apiResponseDataList(dynamic json) {
  final data = apiResponseData(json);
  if (data is List) return data;
  if (data is Map && data['items'] is List) return data['items'] as List;
  if (data is Map && data['data'] is List) return data['data'] as List;
  if (json is Map && json['items'] is List) return json['items'] as List;
  return const [];
}
