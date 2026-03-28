class GetMyShopInventoryResponse {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stockCount;
  final String? imageUrl;

  GetMyShopInventoryResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stockCount,
    this.imageUrl,
  });

  factory GetMyShopInventoryResponse.fromJson(Map<String, dynamic> json) {
    return GetMyShopInventoryResponse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      unit: json['unit'] as String? ?? '',
      stockCount: json['stockCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class GetMyShopListInventoryResponse {
  final List<GetMyShopInventoryResponse> shops;
  final int statusCode;

  GetMyShopListInventoryResponse({required this.shops, required this.statusCode});

  factory GetMyShopListInventoryResponse.fromJson(List<dynamic> json, int statusCode) {
    return GetMyShopListInventoryResponse(
      shops: json.map((e) => GetMyShopInventoryResponse.fromJson(e as Map<String, dynamic>)).toList(),
      statusCode: statusCode,
    );
  }
}
