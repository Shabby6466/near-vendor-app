import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String? shopId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final String? imageUrl;
  final bool isAvailable;
  final double? discount;

  const Item({
    required this.id,
    this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrl,
    this.isAvailable = true,
    this.discount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String? ?? '',
      shopId: json['shopId'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      unit: json['unit'] as String? ?? '',
      stockCount: json['stockCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) : null,
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
      'imageUrl': imageUrl,
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
        imageUrl,
        isAvailable,
        discount,
      ];
}
