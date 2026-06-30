import 'package:nearvendorapp/models/api_responses/base_api_response.dart';

class AnalyticsStatsResponse extends BaseApiResponse {
  final List<AnalyticsStatEntry> data;

  AnalyticsStatsResponse({
    super.statusCode,
    super.message,
    required this.data,
  });

  factory AnalyticsStatsResponse.fromJson(dynamic json) {
    if (json is Map) {
      return AnalyticsStatsResponse(
        statusCode: json['statusCode'] as int?,
        message: json['message'] as String?,
        data: (json['data'] as List? ?? [])
            .map((e) => AnalyticsStatEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return AnalyticsStatsResponse(
      statusCode: 500,
      message: 'Unexpected response format',
      data: const [],
    );
  }
}

class AnalyticsStatEntry {
  final String type;
  final int count;
  final DateTime date;

  AnalyticsStatEntry({
    required this.type,
    required this.count,
    required this.date,
  });

  factory AnalyticsStatEntry.fromJson(Map<String, dynamic> json) {
    return AnalyticsStatEntry(
      type: json['type'] as String? ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }
}
