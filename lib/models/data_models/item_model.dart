import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final String? imageUrl;
  final double discount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrl,
    this.discount = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String? ?? '',
      shopId: json['shopId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      unit: json['unit'] as String? ?? '',
      stockCount: json['stockCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      discount: double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
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
        discount,
      ];
}
