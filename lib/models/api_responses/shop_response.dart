import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/api_responses/search_api_responses.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';

class ShopResponse extends BaseApiResponse {
  final Shop? shop;

  ShopResponse({super.success, super.status, super.message, this.shop});

  factory ShopResponse.fromJson(dynamic json) {
    if (json is Map) {
      final status = (json['statusCode'] as num?)?.toInt() ?? 200;
      final data = apiResponseData(json);
      final shopJson = data is Map && data['shop'] != null ? data['shop'] : data;
      return ShopResponse(
        success: json['success'] as bool? ?? (status == 200 || status == 201),
        status: status,
        message: json['message'] as String? ?? '',
        shop: shopJson is Map<String, dynamic> ? Shop.fromJson(shopJson) : null,
      );
    }
    return ShopResponse(
      success: false,
      status: 500,
      message: 'Unexpected response format',
    );
  }
}

class ShopListResponse extends BaseApiResponse {
  final List<Shop> shops;
  final SearchMeta? meta;
  final bool isGlobalFallback;
  final String? rangeMessage;

  ShopListResponse({
    super.success,
    super.status,
    super.message,
    required this.shops,
    this.meta,
    this.isGlobalFallback = false,
    this.rangeMessage,
  });

  factory ShopListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ShopListResponse(
        success: true,
        status: 200,
        message: 'Success',
        shops: json
            .map((e) => Shop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (json is Map) {
      final data = json['data'];
      List<dynamic>? shopsData;
      SearchMeta? meta;
 
      if (data is Map) {
        shopsData =
            (data['items'] as List<dynamic>?) ??
            (data['shops'] as List<dynamic>?);
        if (data['meta'] != null) {
          meta = SearchMeta.fromJson(data['meta']);
        }
      } else if (data is List<dynamic>) {
        shopsData = data;
      }
 
      // Fallback to root level if no data or data is not a list
      shopsData ??=
          (json['items'] as List<dynamic>?) ??
          (json['shops'] as List<dynamic>?);
 
      if (meta == null && json['meta'] != null) {
        meta = SearchMeta.fromJson(json['meta']);
      }
 
      return ShopListResponse(
        success: json['success'] as bool? ?? (shopsData != null),
        status: (json['statusCode'] as num?)?.toInt() ?? 200,
        message: json['message'] as String? ?? '',
        shops:
            shopsData
                ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        meta: meta,
        isGlobalFallback: data is Map
            ? data['isGlobalFallback'] as bool? ?? false
            : json['isGlobalFallback'] as bool? ?? false,
        rangeMessage: data is Map
            ? data['rangeMessage'] as String? ?? json['message'] as String?
            : json['rangeMessage'] as String? ?? json['message'] as String?,
      );
    }

    return ShopListResponse(
      success: false,
      status: 500,
      message: 'Unexpected response format',
      shops: [],
    );
  }
}
