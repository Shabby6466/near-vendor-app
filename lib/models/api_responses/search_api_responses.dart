import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';

class SearchItemResponse extends BaseApiResponse {
  final List<Product> items;
  final SearchMeta? meta;
  final bool isGlobalFallback;
  final String? rangeMessage;
  final double? radiusUsed;
  final bool hasMoreBeyondRadius;

  SearchItemResponse({
    super.success,
    super.status,
    super.message,
    required this.items,
    this.meta,
    this.isGlobalFallback = false,
    this.rangeMessage,
    this.radiusUsed,
    this.hasMoreBeyondRadius = false,
  });

  factory SearchItemResponse.fromJson(dynamic json) {
    if (json is Map) {
      final data = apiResponseData(json);
      final itemsData = apiResponseDataList(json);
      final metaJson = data is Map
          ? data['meta'] as Map?
          : json['meta'] as Map?;
      
      final radiusUsed = (json['radiusUsed'] as num?)?.toDouble() ??
          (metaJson?['radiusUsed'] as num?)?.toDouble();
      final hasMoreBeyondRadius = json['hasMoreBeyondRadius'] as bool? ??
          metaJson?['hasMoreBeyondRadius'] as bool? ??
          false;

      return SearchItemResponse(
        success: json['success'] as bool? ?? false,
        status: (json['statusCode'] as num?)?.toInt() ?? 200,
        items: itemsData
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: metaJson != null ? SearchMeta.fromJson(metaJson) : null,
        message: json['message'] as String?,
        isGlobalFallback: data is Map
            ? data['isGlobalFallback'] as bool? ?? false
            : json['isGlobalFallback'] as bool? ?? false,
        rangeMessage: data is Map
            ? data['rangeMessage'] as String?
            : json['rangeMessage'] as String?,
        radiusUsed: radiusUsed,
        hasMoreBeyondRadius: hasMoreBeyondRadius,
      );
    }
    return SearchItemResponse(
      success: false,
      status: 500,
      items: const [],
      message: 'Unexpected response format',
    );
  }
}

class SearchMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  SearchMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory SearchMeta.fromJson(dynamic json) {
    if (json is Map) {
      return SearchMeta(
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
        itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      );
    }
    return SearchMeta(
      totalItems: 0,
      itemCount: 0,
      itemsPerPage: 0,
      totalPages: 0,
      currentPage: 0,
    );
  }
}
