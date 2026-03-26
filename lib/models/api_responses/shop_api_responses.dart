class ShopResponse {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String shopName;
  final String? shopImageUrl;
  final String whatsappNumber;
  final String shopAddress;
  final bool isActive;
  final double shopLongitude;
  final double shopLatitude;
  final Map<String, String> operatingHours;
  final String vendorId;
  final String businessCategory;
  final String registrationNumber;
  final String shopContactPhone;
  final String storeEmail;
  final String? coverImageUrl;
  final String? storeLogoUrl;

  ShopResponse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.shopName,
    this.shopImageUrl,
    required this.whatsappNumber,
    required this.shopAddress,
    required this.isActive,
    required this.shopLongitude,
    required this.shopLatitude,
    required this.operatingHours,
    required this.vendorId,
    required this.businessCategory,
    required this.registrationNumber,
    required this.shopContactPhone,
    required this.storeEmail,
    this.coverImageUrl,
    this.storeLogoUrl,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      shopName: json['shopName'],
      shopImageUrl: json['shopImageUrl'],
      whatsappNumber: json['whatsappNumber'],
      shopAddress: json['shopAddress'],
      isActive: json['isActive'],
      shopLongitude: (json['shopLongitude'] as num).toDouble(),
      shopLatitude: (json['shopLatitude'] as num).toDouble(),
      operatingHours: Map<String, String>.from(json['operatingHours']),
      vendorId: json['vendorId'],
      businessCategory: json['businessCategory'],
      registrationNumber: json['registrationNumber'],
      shopContactPhone: json['shopContactPhone'],
      storeEmail: json['storeEmail'],
      coverImageUrl: json['coverImageUrl'],
      storeLogoUrl: json['storeLogoUrl'],
    );
  }
}

class ShopListResponse {
  final List<ShopResponse> shops;
  final int statusCode;

  ShopListResponse({required this.shops, required this.statusCode});

  factory ShopListResponse.fromJson(List<dynamic> json, int statusCode) {
    return ShopListResponse(
      shops: json.map((e) => ShopResponse.fromJson(e as Map<String, dynamic>)).toList(),
      statusCode: statusCode,
    );
  }
}
