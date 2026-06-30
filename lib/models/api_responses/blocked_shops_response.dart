import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/models/data_models/blocked_shop.dart';

class BlockedShopsResponse extends BaseApiResponse {
  final List<BlockedShop> shops;

  BlockedShopsResponse({
    super.status,
    super.statusCode,
    super.message,
    required this.shops,
  });

  factory BlockedShopsResponse.fromJson(dynamic json) {
    if (json is Map) {
      final status = (json['statusCode'] as num?)?.toInt() ?? 200;
      final rawData = apiResponseData(json);
      final shopsData = rawData is List ? rawData : [];
      return BlockedShopsResponse(
        statusCode: status,
        message: json['message'] as String? ?? '',
        shops: shopsData
            .map((e) => BlockedShop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return BlockedShopsResponse(
      statusCode: 500,
      message: 'Unexpected response format',
      shops: const [],
    );
  }
}
