class BaseApiResponse {
  final bool? success;
  final int? status;
  final String? message;

  BaseApiResponse({this.success, this.status, this.message});

  BaseApiResponse.fromJson(Map<String, dynamic> json)
    : success = json['success'] is bool
          ? json['success'] as bool
          : json['statusCode'] != null
          ? (json['statusCode'] as num).toInt() >= 200 &&
                (json['statusCode'] as num).toInt() < 300
          : null,
      status = (json['statusCode'] as num?)?.toInt(),
      message = json['message'] as String?;

  Map<String, dynamic> toJson() {
    return {'success': success, 'statusCode': status, 'message': message};
  }
}
