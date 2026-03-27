import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String id;
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
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Shop({
    required this.id,
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
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      shopName: json['shopName'] as String? ?? 'Unnamed Shop',
      businessCategory: json['businessCategory'] as String? ?? 'General',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      shopAddress: json['shopAddress'] as String? ?? '',
      operatingHours: (json['operatingHours'] as Map<String, dynamic>?) ?? {},
      shopLongitude: double.tryParse(json['shopLongitude']?.toString() ?? '0.0') ?? 0.0,
      shopLatitude: double.tryParse(json['shopLatitude']?.toString() ?? '0.0') ?? 0.0,
      shopContactPhone: json['shopContactPhone'] as String? ?? '',
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      storeEmail: json['storeEmail'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      storeLogoUrl: json['storeLogoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

  @override
  List<Object?> get props => [
        id,
        vendorId,
        shopName,
        businessCategory,
        registrationNumber,
        shopAddress,
        operatingHours,
        shopLongitude,
        shopLatitude,
        shopContactPhone,
        whatsappNumber,
        storeEmail,
        coverImageUrl,
        storeLogoUrl,
        isActive,
      ];
}
