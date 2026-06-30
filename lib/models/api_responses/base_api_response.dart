class BaseApiResponse {
  final int statusCode;
  final String message;

  BaseApiResponse({
    int? status,
    int? statusCode,
    String? message,
  })  : statusCode = (statusCode ?? status ?? 200).toInt(),
        message = message ?? 'Success';

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  // Keep compatibility for any callers checking success or status properties
  bool get success => isSuccess;
  int get status => statusCode;

  BaseApiResponse.fromJson(dynamic json)
      : statusCode = json is Map
            ? (json['statusCode'] as num? ?? json['status'] as num? ?? 200).toInt()
            : 500,
        message = json is Map
            ? (json['message'] as String? ?? 'Success')
            : 'Request failed';

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
