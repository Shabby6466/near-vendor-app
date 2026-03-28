import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class LocationSuggestion {
  final String displayName;
  final LatLng location;

  LocationSuggestion({required this.displayName, required this.location});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      location: LatLng(
        double.parse(json['lat']),
        double.parse(json['lon']),
      ),
    );
  }
}

class LocationService {
  final Dio _dio = Dio();

  Future<List<LocationSuggestion>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
        },
        options: Options(
          headers: {
            'User-Agent': 'nearvendorapp/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => LocationSuggestion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }
}
