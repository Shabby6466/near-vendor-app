import 'package:nearvendorapp/models/data_models/item_model.dart';

class ItemResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Item? item;

  ItemResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.item,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      item: (json['data'] != null)
          ? Item.fromJson(json['data'] as Map<String, dynamic>)
          : (json['item'] != null)
              ? Item.fromJson(json['item'] as Map<String, dynamic>)
              : null,
    );
  }
}

class PaginationMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  PaginationMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
    );
  }
}

class ItemListResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Item> items;
  final PaginationMeta? meta;

  ItemListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.items,
    this.meta,
  });

  factory ItemListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ItemListResponse(
        success: true,
        statusCode: 200,
        message: 'Success',
        items: json
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      final dataObj = json['data'];
      List<dynamic>? itemsList;
      Map<String, dynamic>? metaData;

      if (dataObj is List) {
        itemsList = dataObj;
      } else if (dataObj is Map<String, dynamic>) {
        itemsList = dataObj['items'] as List<dynamic>?;
        metaData = dataObj['meta'] as Map<String, dynamic>?;
      }

      metaData ??= json['meta'] as Map<String, dynamic>?;

      final hasData = itemsList != null;

      return ItemListResponse(
        success: json['success'] as bool? ?? hasData,
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? (hasData ? 'Success' : ''),
        items:
            itemsList
                ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        meta: metaData != null ? PaginationMeta.fromJson(metaData) : null,
      );
    }

    return ItemListResponse(
      success: false,
      statusCode: 500,
      message: 'Unexpected response format',
      items: [],
    );
  }
}
