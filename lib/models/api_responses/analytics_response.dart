class AnalyticsStatsResponse {
  final bool success;
  final int statusCode;
  final List<AnalyticsStatEntry> data;

  AnalyticsStatsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory AnalyticsStatsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsStatsResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => AnalyticsStatEntry.fromJson(e))
          .toList(),
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
      type: json['type'] ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}
