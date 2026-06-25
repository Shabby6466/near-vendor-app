import 'package:nearvendorapp/models/api_responses/base_api_response.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/blocked_shops_screen/cubit/blocked_shops_cubit.dart';

class BlockedShopsResponse extends BaseApiResponse {
  final List<BlockedShop> shops;

  BlockedShopsResponse({
    super.success,
    super.status,
    super.message,
    required this.shops,
  });

  factory BlockedShopsResponse.fromJson(dynamic json) {
    if (json is Map) {
      final status = (json['statusCode'] as num?)?.toInt() ?? 200;
      final rawData = apiResponseData(json);
      final shopsData = rawData is List ? rawData : [];
      return BlockedShopsResponse(
        success: json['success'] as bool? ?? (status == 200 || status == 201),
        status: status,
        message: json['message'] as String? ?? '',
        shops: shopsData
            .map((e) => BlockedShop.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return BlockedShopsResponse(
      success: false,
      status: 500,
      message: 'Unexpected response format',
      shops: [],
    );
  }
}
