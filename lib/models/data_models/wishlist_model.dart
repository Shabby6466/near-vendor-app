import 'package:equatable/equatable.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';

class WishlistItem extends Equatable {
  final String id;
  final String itemName;
  final String? description;
  final String? categoryId;
  final String status;
  final DateTime? createdAt;
  final List<Item> matchedItems;

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
    var matches = json['matchedItems'] as List?;
    return WishlistItem(
      id: json['id'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      matchedItems: matches != null
          ? matches.map((i) => Item.fromJson(Map<String, dynamic>.from(i))).toList()
          : [],
    );
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
