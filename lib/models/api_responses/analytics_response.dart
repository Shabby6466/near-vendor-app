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

class ShopInsightsResponse {
  final bool success;
  final int statusCode;
  final ShopInsightsData data;

  ShopInsightsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory ShopInsightsResponse.fromJson(Map<String, dynamic> json) {
    return ShopInsightsResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      data: ShopInsightsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ShopInsightsData {
  final InsightsSummary summary;
  final List<dynamic> topKeywords;
  final List<HistoricalEntry> historical;

  ShopInsightsData({
    required this.summary,
    required this.topKeywords,
    required this.historical,
  });

  factory ShopInsightsData.fromJson(Map<String, dynamic> json) {
    return ShopInsightsData(
      summary: InsightsSummary.fromJson(json['summary'] ?? {}),
      topKeywords: json['topKeywords'] as List? ?? [],
      historical: (json['historical'] as List? ?? [])
          .map((e) => HistoricalEntry.fromJson(e))
          .toList(),
    );
  }
}

class InsightsSummary {
  final int impressions;
  final int views;
  final double ctr;

  InsightsSummary({
    required this.impressions,
    required this.views,
    required this.ctr,
  });

  factory InsightsSummary.fromJson(Map<String, dynamic> json) {
    return InsightsSummary(
      impressions: json['impressions'] ?? 0,
      views: json['views'] ?? 0,
      ctr: (json['ctr'] as num? ?? 0.0).toDouble(),
    );
  }
}

class HistoricalEntry {
  final String type;
  final int count;

  HistoricalEntry({
    required this.type,
    required this.count,
  });

  factory HistoricalEntry.fromJson(Map<String, dynamic> json) {
    return HistoricalEntry(
      type: json['type'] ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}

class PortfolioAnalyticsResponse {
  final bool success;
  final int statusCode;
  final List<PortfolioEntry> data;

  PortfolioAnalyticsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory PortfolioAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioAnalyticsResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => PortfolioEntry.fromJson(e))
          .toList(),
    );
  }
}

class PortfolioEntry {
  final String shopId;
  final String type;
  final int count;

  PortfolioEntry({
    required this.shopId,
    required this.type,
    required this.count,
  });

  factory PortfolioEntry.fromJson(Map<String, dynamic> json) {
    return PortfolioEntry(
      shopId: json['shopId'] ?? '',
      type: json['type'] ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}

class MarketInsightsResponse {
  final bool success;
  final int statusCode;
  final MarketInsightsData data;

  MarketInsightsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory MarketInsightsResponse.fromJson(Map<String, dynamic> json) {
    return MarketInsightsResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      data: MarketInsightsData.fromJson(json['data'] ?? {}),
    );
  }
}

class MarketInsightsData {
  final List<DemandEntry> neighborhoodDemand;
  final List<dynamic> unmetDemand;
  final double radiusMeters;

  MarketInsightsData({
    required this.neighborhoodDemand,
    required this.unmetDemand,
    required this.radiusMeters,
  });

  factory MarketInsightsData.fromJson(Map<String, dynamic> json) {
    return MarketInsightsData(
      neighborhoodDemand: (json['neighborhoodDemand'] as List? ?? [])
          .map((e) => DemandEntry.fromJson(e))
          .toList(),
      unmetDemand: json['unmetDemand'] as List? ?? [],
      radiusMeters: (json['radiusMeters'] as num? ?? 0.0).toDouble(),
    );
  }
}

class DemandEntry {
  final String query;
  final int count;

  DemandEntry({
    required this.query,
    required this.count,
  });

  factory DemandEntry.fromJson(Map<String, dynamic> json) {
    return DemandEntry(
      query: json['query'] ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}
