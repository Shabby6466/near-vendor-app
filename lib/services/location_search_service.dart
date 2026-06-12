import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng location;

  LocationSuggestion({required this.displayName, required this.location});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] as String? ?? '',
      location: LatLng(
        double.parse(json['lat'] as String),
        double.parse(json['lon'] as String),
      ),
    );
  }
}

class LocationSearchService {
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
        //TODO: parsing should be in response model class
        final List data = response.data as List;
        return data
            .map(
              (json) =>
                  LocationSuggestion.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }
}
