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

  ShopListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.shops,
  });

  factory ShopListResponse.fromJson(dynamic json) {
    if (json is List) {
      final List<dynamic> shopsData = json.isNotEmpty ? json[0] as List<dynamic> : [];
      return ShopListResponse(
        success: true,
        statusCode: 200,
        message: 'Success',
        shops: shopsData
            .map((e) => Shop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      return ShopListResponse(
        success: json['success'] as bool? ?? false,
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        shops: (json['shops'] as List<dynamic>?)
                ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
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
