class CreateItemInput {
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final List<String> imageUrls;
  final double? discount;

  CreateItemInput({
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrls = const [],
    this.discount,
  });

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'stockCount': stockCount,
        'imageUrls': imageUrls,
        'discount': discount,
      };
}

class UpdateItemInput {
  final String id;
  final String? name;
  final String? description;
  final double? price;
  final String? unit;
  final int? stockCount;
  final List<String>? imageUrls;
  final double? discount;

  UpdateItemInput({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.unit,
    this.stockCount,
    this.imageUrls,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (unit != null) data['unit'] = unit;
    if (stockCount != null) data['stockCount'] = stockCount;
    if (imageUrls != null) data['imageUrls'] = imageUrls;
    if (discount != null) data['discount'] = discount;
    return data;
  }
}
