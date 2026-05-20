import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

/// GPS, geocoding, and profile sync for [AppData] location.
class AppLocationService {
  AppLocationService._();

  static final AppLocationService instance = AppLocationService._();

  final AuthServices _authServices = AuthServices();
  final AppData _appData = AppData();

  Future<void> updateFromGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placeName = await _getPlaceName(
        position.latitude,
        position.longitude,
      );

      await saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: placeName,
      );
    } catch (e) {
      debugPrint('Error updating location from GPS: $e');
    }
  }

  Future<LatLng?> saveLocation({
    required double latitude,
    required double longitude,
    String? placeName,
    bool syncProfile = true,
  }) async {
    try {
      final resolvedName =
          placeName ?? await _getPlaceName(latitude, longitude);

      await _appData.setLocation(
        latitude,
        longitude,
        placeName: resolvedName,
      );

      if (syncProfile && _appData.isLoggedIn) {
        await _authServices.updateUser(
          UpdateUserInput(latitude: latitude, longitude: longitude),
        );
      }

      return LatLng(latitude, longitude);
    } catch (e) {
      debugPrint('Error saving location: $e');
      return null;
    }
  }

  Future<void> resolvePlaceNameIfMissing() async {
    final loc = _appData.location;
    if (loc == null || loc.hasPlaceName) return;

    final name = await _getPlaceName(loc.latitude, loc.longitude);
    if (name == null) return;

    await _appData.setLocation(loc.latitude, loc.longitude, placeName: name);
  }

  Future<String?> _getPlaceName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea;
      final country = place.country;
      if (city != null && country != null) return '$city, $country';
      return city;
    } catch (e) {
      debugPrint('Error getting place name: $e');
      return null;
    }
  }
}
