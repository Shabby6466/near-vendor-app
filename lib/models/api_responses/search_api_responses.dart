import 'package:nearvendorapp/models/data_models/item_model.dart';

class SearchItemResponse {
  final bool success;
  final int statusCode;
  final List<Item> items;
  final SearchMeta? meta;
  final String? message;

  SearchItemResponse({
    required this.success,
    required this.statusCode,
    required this.items,
    this.meta,
    this.message,
  });

  factory SearchItemResponse.fromJson(Map<String, dynamic> json) {
    return SearchItemResponse(
      success: json['success'] as bool? ?? false,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      items: (json['data'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: json['meta'] != null ? SearchMeta.fromJson(json['meta']) : null,
      message: json['message'] as String?,
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

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
    );
  }
}
