import 'package:equatable/equatable.dart';

class BlockedShop extends Equatable {
  final String blockedShopId;
  final String shopName;
  final String shopLogoUrl;

  const BlockedShop({
    required this.blockedShopId,
    required this.shopName,
    required this.shopLogoUrl,
  });

  factory BlockedShop.fromJson(Map<String, dynamic> json) {
    return BlockedShop(
      blockedShopId: json['blockedShopId'] as String? ?? '',
      shopName: json['shopName'] as String? ?? 'Shop',
      shopLogoUrl: json['shopLogoUrl'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [blockedShopId, shopName, shopLogoUrl];
}
