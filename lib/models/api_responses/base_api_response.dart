class BaseApiResponse {
  final int? statusCode;
  final String? message;

  BaseApiResponse({
    this.statusCode,
    this.message,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  // Keep compatibility for any callers checking success property
  bool get success => isSuccess;

  BaseApiResponse.fromJson(dynamic json)
      : statusCode = json is Map
            ? (json['statusCode'] as num?)?.toInt()
            : null,
        message = json is Map ? json['message'] as String? : null;

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'message': message};
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
  if (data is Map) {
    if (data.containsKey('items') && data['items'] is List) {
      return data['items'] as List;
    }
    if (data.containsKey('products') && data['products'] is List) {
      return data['products'] as List;
    }
  }
  return const [];
}
