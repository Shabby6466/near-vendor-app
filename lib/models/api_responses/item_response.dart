import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';

class ItemResponse extends BaseApiResponse {
  final Item? item;

  ItemResponse({super.success, super.status, super.message, this.item});

  ItemResponse.fromJson(Map<String, dynamic> json)
    : item = _parseItem(json),
      super.fromJson(json);

  static Item? _parseItem(Map<String, dynamic> json) {
    final data = apiResponseData(json);
    final itemJson = data is Map && data['item'] != null ? data['item'] : data;
    return itemJson is Map<String, dynamic> ? Item.fromJson(itemJson) : null;
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

class ItemListResponse extends BaseApiResponse {
  final List<Item> items;
  final PaginationMeta? meta;

  ItemListResponse({
    super.success,
    super.status,
    super.message,
    required this.items,
    this.meta,
  });

  factory ItemListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ItemListResponse(
        success: true,
        status: 200,
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

      itemsList ??= apiResponseDataList(json);

      metaData ??= json['meta'] as Map<String, dynamic>?;

      return ItemListResponse(
        success: json['success'] as bool? ?? true,
        status: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? 'Success',
        items: itemsList
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: metaData != null ? PaginationMeta.fromJson(metaData) : null,
      );
    }

    return ItemListResponse(
      success: false,
      status: 500,
      message: 'Unexpected response format',
      items: [],
    );
  }
}
