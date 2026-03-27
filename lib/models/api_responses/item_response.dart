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
      item: json['item'] != null ? Item.fromJson(json['item'] as Map<String, dynamic>) : null,
    );
  }
}

class ItemListResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Item> items;

  ItemListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.items,
  });

  factory ItemListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ItemListResponse(
        success: true,
        statusCode: 200,
        message: 'Success',
        items: json.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    
    if (json is Map<String, dynamic>) {
      return ItemListResponse(
        success: json['success'] as bool? ?? false,
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
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
