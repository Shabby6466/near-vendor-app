class SearchItemInput {
  final double lat;
  final double lon;
  final int radius;
  final int page;
  final int limit;
  final String query;

  SearchItemInput({
    required this.lat,
    required this.lon,
    this.radius = 10000,
    this.page = 1,
    this.limit = 10,
    required this.query,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'radius': radius,
        'page': page,
        'limit': limit,
        'query': query,
      };
}
