class CreateItemInput {
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final String? imageUrl;
  final double? discount;

  CreateItemInput({
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrl,
    this.discount,
  });

  Map<String, dynamic> toJson() => {
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

class UpdateItemInput {
  final String id;
  final String? name;
  final String? description;
  final double? price;
  final String? unit;
  final int? stockCount;
  final String? imageUrl;
  final double? discount;

  UpdateItemInput({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.unit,
    this.stockCount,
    this.imageUrl,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (unit != null) data['unit'] = unit;
    if (stockCount != null) data['stockCount'] = stockCount;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (discount != null) data['discount'] = discount;
    return data;
  }
}
