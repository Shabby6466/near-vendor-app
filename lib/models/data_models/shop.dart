import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String? id;
  final String? vendorId;
  final String? shopName;
  final String? categoryId;
  final String? businessCategory;
  final String? registrationNumber;
  final String? shopAddress;
  final Map<String, dynamic>? operatingHours;
  final String? timezone;
  final Map<String, dynamic>? openingHours;
  final String? currency;
  final double? shopLongitude;
  final double? shopLatitude;
  final String? shopContactPhone;
  final String? whatsappNumber;
  final String? storeEmail;
  final String? coverImageUrl;
  final String? storeLogoUrl;
  final bool? isActive;
  final int? completionPercentage;
  final bool? isVerifiedBadge;
  final bool? isRecentlyActive;
  final int? itemCount;
  final double? distance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Shop({
    this.id,
    this.vendorId,
    this.shopName,
    this.categoryId,
    this.businessCategory,
    this.registrationNumber,
    this.shopAddress,
    this.operatingHours,
    this.timezone,
    this.openingHours,
    this.currency,
    this.shopLongitude,
    this.shopLatitude,
    this.shopContactPhone,
    this.whatsappNumber,
    this.storeEmail,
    this.coverImageUrl,
    this.storeLogoUrl,
    this.isActive,
    this.completionPercentage,
    this.isVerifiedBadge,
    this.isRecentlyActive,
    this.itemCount,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Helper closures to check and extract Map types cleanly
    Map<String, dynamic>? parseMap(dynamic value) {
      return value is Map ? Map<String, dynamic>.from(value) : null;
    }

    return Shop(
      id: json['id'] as String?,
      vendorId: json['vendorId'] as String?,
      shopName: json['shopName'] as String?,
      categoryId:
          json['categoryId'] as String? ?? json['category_id'] as String?,
      businessCategory: json['businessCategory'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      shopAddress: json['shopAddress'] as String?,
      operatingHours: parseMap(json['operatingHours'] ?? json['openingHours']),
      timezone: json['timezone'] as String?,
      openingHours: parseMap(json['openingHours'] ?? json['operatingHours']),
      currency: json['currency'] as String?,
      shopLongitude: double.tryParse(
        (json['shopLongitude'] ?? json['longitude'])?.toString() ?? '',
      ),
      shopLatitude: double.tryParse(
        (json['shopLatitude'] ?? json['latitude'])?.toString() ?? '',
      ),
      shopContactPhone: json['shopContactPhone'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      storeEmail: json['storeEmail'] as String?,
      coverImageUrl:
          json['coverImageUrl'] as String? ??
          json['shopImageUrl'] as String? ??
          json['shopLogoUrl'] as String?,
      storeLogoUrl:
          json['storeLogoUrl'] as String? ?? json['shopLogoUrl'] as String?,
      isActive: json['isActive'] as bool?,
      completionPercentage: json['completionPercentage'] is int
          ? json['completionPercentage'] as int
          : int.tryParse(json['completionPercentage']?.toString() ?? ''),
      isVerifiedBadge: json['isVerifiedBadge'] as bool?,
      isRecentlyActive: json['isRecentlyActive'] as bool?,
      itemCount: json['itemCount'] is int
          ? json['itemCount'] as int
          : int.tryParse(json['itemCount']?.toString() ?? ''),
      distance: double.tryParse(json['distance']?.toString() ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'shopName': shopName,
      'categoryId': categoryId,
      'businessCategory': businessCategory,
      'registrationNumber': registrationNumber,
      'shopAddress': shopAddress,
      'operatingHours': operatingHours,
      'timezone': timezone,
      'openingHours': openingHours,
      'currency': currency,
      'shopLongitude': shopLongitude,
      'shopLatitude': shopLatitude,
      'shopContactPhone': shopContactPhone,
      'whatsappNumber': whatsappNumber,
      'storeEmail': storeEmail,
      'shopImageUrl': coverImageUrl,
      'shopLogoUrl': storeLogoUrl,
      'isActive': isActive,
      'completionPercentage': completionPercentage,
      'isVerifiedBadge': isVerifiedBadge,
      'isRecentlyActive': isRecentlyActive,
      'itemCount': itemCount,
      'distance': distance,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    vendorId,
    shopName,
    categoryId,
    businessCategory,
    registrationNumber,
    shopAddress,
    operatingHours,
    timezone,
    openingHours,
    currency,
    shopLongitude,
    shopLatitude,
    shopContactPhone,
    whatsappNumber,
    storeEmail,
    coverImageUrl,
    storeLogoUrl,
    isActive,
    completionPercentage,
    isVerifiedBadge,
    isRecentlyActive,
    itemCount,
    distance,
    createdAt,
    updatedAt,
  ];
}
