import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String? shopId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final List<String> imageUrls;
  final bool isAvailable;
  final double? discount;
  final Map<String, dynamic>? shop; // For portfolio results
  final int? count; // For performance results
  final double? distanceM;
  final double? visualScore;
  final double? lat;
  final double? long;

  const Item({
    required this.id,
    this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrls = const [],
    this.isAvailable = true,
    this.discount,
    this.shop,
    this.count,
    this.distanceM,
    this.visualScore,
    this.lat,
    this.long,
  });

  /// Primary display image (first in the list, or null)
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory Item.fromJson(Map<String, dynamic> json) {
    // Support both new 'imageUrls' array and legacy 'imageUrl' string
    List<String> urls = [];
    if (json['imageUrls'] != null) {
      urls = List<String>.from(json['imageUrls']);
    } else if (json['imageUrl'] != null && (json['imageUrl'] as String).isNotEmpty) {
      urls = [json['imageUrl'] as String];
    }

    return Item(
      id: json['id'] as String? ?? '',
      shopId: json['shopId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      unit: json['unit'] as String? ?? '',
      stockCount: json['stockCount'] as int? ?? 0,
      imageUrls: urls,
      isAvailable: json['isAvailable'] as bool? ?? true,
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) : null,
      shop: json['shop'] as Map<String, dynamic>?,
      count: json['count'] as int?,
      distanceM: double.tryParse(json['distance_m']?.toString() ?? ''),
      visualScore: double.tryParse(json['visualScore']?.toString() ?? ''),
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      long: double.tryParse(json['long']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stockCount': stockCount,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'discount': discount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        description,
        price,
        unit,
        stockCount,
        imageUrls,
        isAvailable,
        discount,
        shop,
        count,
        distanceM,
        visualScore,
        lat,
        long,
      ];
}
