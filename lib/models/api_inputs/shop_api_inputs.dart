class CreateShopInput {
  final String vendorId;
  final String shopName;
  final String businessCategory;
  final String registrationNumber;
  final String shopAddress;
  final Map<String, dynamic> operatingHours;
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

  Map<String, dynamic> toJson() => {
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
    'shopImageUrl': coverImageUrl,
    'shopLogoUrl': storeLogoUrl,
  };
}

class UpdateShopInput {
  final String shopId;
  final String? shopName;
  final String? businessCategory;
  final String? registrationNumber;
  final String? shopAddress;
  final Map<String, dynamic>? operatingHours;
  final double? shopLongitude;
  final double? shopLatitude;
  final String? shopContactPhone;
  final String? whatsappNumber;
  final String? storeEmail;
  final String? coverImageUrl;
  final String? storeLogoUrl;
  final bool? isActive;

  UpdateShopInput({
    required this.shopId,
    this.shopName,
    this.businessCategory,
    this.registrationNumber,
    this.shopAddress,
    this.operatingHours,
    this.shopLongitude,
    this.shopLatitude,
    this.shopContactPhone,
    this.whatsappNumber,
    this.storeEmail,
    this.coverImageUrl,
    this.storeLogoUrl,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'shopId': shopId};
    if (shopName != null) data['shopName'] = shopName;
    if (businessCategory != null) data['businessCategory'] = businessCategory;
    if (registrationNumber != null)
      data['registrationNumber'] = registrationNumber;
    if (shopAddress != null) data['shopAddress'] = shopAddress;
    if (operatingHours != null) data['operatingHours'] = operatingHours;
    if (shopLongitude != null) data['shopLongitude'] = shopLongitude;
    if (shopLatitude != null) data['shopLatitude'] = shopLatitude;
    if (shopContactPhone != null) data['shopContactPhone'] = shopContactPhone;
    if (whatsappNumber != null) data['whatsappNumber'] = whatsappNumber;
    if (storeEmail != null) data['storeEmail'] = storeEmail;
    if (coverImageUrl != null) data['shopImageUrl'] = coverImageUrl;
    if (storeLogoUrl != null) data['shopLogoUrl'] = storeLogoUrl;
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

class DeleteShopInput {
  final String shopId;

  DeleteShopInput({required this.shopId});

  Map<String, dynamic> toJson() => {'shopId': shopId};
}
