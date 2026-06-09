import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/enums/wishlist_status.dart';
import 'package:nearvendorapp/models/data_models/product_model.dart';

class WishlistItem extends Equatable {
  final String id;
  final String itemName;
  final String? description;
  final String? categoryId;
  final WishlistStatus status;
  final DateTime? createdAt;
  final List<Product> matchedItems;

  const WishlistItem({
    required this.id,
    required this.itemName,
    this.description,
    this.categoryId,
    required this.status,
    this.createdAt,
    this.matchedItems = const [],
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final matches = json['matchedItems'] as List?;
    return WishlistItem(
      id: json['id'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      status: WishlistStatus.fromValue(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      matchedItems: matches != null
          ? matches
                .map((i) => Product.fromJson(i as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'description': description,
      'categoryId': categoryId,
      'status': status.value,
      'createdAt': createdAt?.toIso8601String(),
      'matchedItems': matchedItems.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    itemName,
    description,
    categoryId,
    status,
    createdAt,
    matchedItems,
  ];
}
