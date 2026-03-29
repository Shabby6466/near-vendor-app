import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

class ShopResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Shop? shop;

  ShopResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.shop,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    final statusCode = (json['statusCode'] as num?)?.toInt() ?? 200;
    return ShopResponse(
      success: json['success'] as bool? ?? (statusCode == 200 || statusCode == 201),
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      shop: (json['data'] != null)
          ? Shop.fromJson(json['data'] as Map<String, dynamic>)
          : (json['shop'] != null)
              ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
              : null,
    );
  }
}

class ShopListResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<Shop> shops;
  final SearchMeta? meta;

  ShopListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.shops,
    this.meta,
  });

  factory ShopListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ShopListResponse(
        success: true,
        statusCode: 200,
        message: 'Success',
        shops: json
            .map((e) => Shop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      final data = json['data'];
      List<dynamic>? shopsData;
      SearchMeta? meta;

      if (data is Map<String, dynamic>) {
        shopsData = (data['items'] as List<dynamic>?) ??
            (data['shops'] as List<dynamic>?);
        if (data['meta'] != null) {
          meta = SearchMeta.fromJson(data['meta'] as Map<String, dynamic>);
        }
      } else if (data is List<dynamic>) {
        shopsData = data;
      }

      // Fallback to root level if no data or data is not a list
      shopsData ??= (json['items'] as List<dynamic>?) ??
          (json['shops'] as List<dynamic>?);
      
      if (meta == null && json['meta'] != null) {
        meta = SearchMeta.fromJson(json['meta'] as Map<String, dynamic>);
      }

      return ShopListResponse(
        success: json['success'] as bool? ?? (shopsData != null),
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        shops: shopsData
                ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        meta: meta,
      );
    }

    return ShopListResponse(
      success: false,
      statusCode: 500,
      message: 'Unexpected response format',
      shops: [],
    );
  }
}
