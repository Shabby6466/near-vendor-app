import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng location;

  LocationSuggestion({required this.displayName, required this.location});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      location: LatLng(double.parse(json['lat']), double.parse(json['lon'])),
    );
  }
}

class LocationService {
  final Dio _dio = Dio();

  Future<List<LocationSuggestion>> getSuggestions(
    String query, {
    double? lat,
    double? lon,
  }) async {
    if (query.isEmpty) return [];

    try {
      final queryParams = {
        'q': query,
        'format': 'json',
        'limit': 10,
        'addressdetails': 1,
        'accept-language': 'en',
      };

      if (lat != null && lon != null) {
        // Bias results towards current location
        queryParams['lat'] = lat.toString();
        queryParams['lon'] = lon.toString();
        // and add a small viewbox around the location for stronger biasing
        queryParams['viewbox'] =
            '${lon - 0.1},${lat + 0.1},${lon + 0.1},${lat - 0.1}';
      }

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: queryParams,
        options: Options(headers: {'User-Agent': 'nearvendorapp/1.0'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => LocationSuggestion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }
}
