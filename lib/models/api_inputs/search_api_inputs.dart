class SearchItemInput {
  final double lat;
  final double lon;
  final int radius;
  final int page;
  final int limit;
  final String query;
  final String? categoryId;
  final String? shopId;

  SearchItemInput({
    required this.lat,
    required this.lon,
    this.radius = 10000,
    this.page = 1,
    this.limit = 10,
    required this.query,
    this.categoryId,
    this.shopId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'lat': double.parse(lat.toStringAsFixed(7)),
      'lon': double.parse(lon.toStringAsFixed(7)),
      'radius': radius,
      'page': page,
      'limit': limit,
      'query': query,
    };
    if (categoryId != null) data['categoryId'] = categoryId;
    if (shopId != null) data['shopId'] = shopId;
    return data;
  }
}
