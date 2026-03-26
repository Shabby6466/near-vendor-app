class CreateShopInput {
  final String vendorId;
  final String shopName;
  final String businessCategory;
  final String registrationNumber;
  final String shopAddress;
  final Map<String, String> operatingHours;
  final double shopLongitude;
  final double shopLatitude;
  final String shopContactPhone;
  final String whatsappNumber;
  final String storeEmail;
  final String? coverImageUrl;
  final String? storeLogoUrl;

  CreateShopInput({
    required this.vendorId,
    required this.shopName,
    required this.businessCategory,
    required this.registrationNumber,
    required this.shopAddress,
    required this.operatingHours,
    required this.shopLongitude,
    required this.shopLatitude,
    required this.shopContactPhone,
    required this.whatsappNumber,
    required this.storeEmail,
    this.coverImageUrl,
    this.storeLogoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'shopName': shopName,
      'businessCategory': businessCategory,
      'registrationNumber': registrationNumber,
      'shopAddress': shopAddress,
      'operatingHours': operatingHours,
      'shopLongitude': shopLongitude,
      'shopLatitude': shopLatitude,
      'shopContactPhone': shopContactPhone,
      'whatsappNumber': whatsappNumber,
      'storeEmail': storeEmail,
      'coverImageUrl': coverImageUrl,
      'storeLogoUrl': storeLogoUrl,
    };
  }
}

class UpdateShopInput {
  final String vendorId;
  final String shopName;
  final String businessCategory;
  final String registrationNumber;
  final String shopAddress;
  final Map<String, String> operatingHours;
  final double shopLongitude;
  final double shopLatitude;
  final String shopContactPhone;
  final String whatsappNumber;
  final String storeEmail;
  final String? coverImageUrl;
  final String? storeLogoUrl;
  final bool isActive;

  UpdateShopInput({
    required this.vendorId,
    required this.shopName,
    required this.businessCategory,
    required this.registrationNumber,
    required this.shopAddress,
    required this.operatingHours,
    required this.shopLongitude,
    required this.shopLatitude,
    required this.shopContactPhone,
    required this.whatsappNumber,
    required this.storeEmail,
    this.coverImageUrl,
    this.storeLogoUrl,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'shopName': shopName,
      'businessCategory': businessCategory,
      'registrationNumber': registrationNumber,
      'shopAddress': shopAddress,
      'operatingHours': operatingHours,
      'shopLongitude': shopLongitude,
      'shopLatitude': shopLatitude,
      'shopContactPhone': shopContactPhone,
      'whatsappNumber': whatsappNumber,
      'storeEmail': storeEmail,
      'coverImageUrl': coverImageUrl,
      'storeLogoUrl': storeLogoUrl,
      'isActive': isActive,
    };
  }
}

class DeleteShopInput {
  final String shopId;

  DeleteShopInput({required this.shopId});

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
    };
  }
}
