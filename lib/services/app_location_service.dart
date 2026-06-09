import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';

class AppLocationService {
  AppLocationService._();

  static final AppLocationService instance = AppLocationService._();

  final AuthServices _authServices = AuthServices();
  final AppData _appData = AppData();

  /// Checks if location permission is granted.
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Request permissions from the platform.
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  /// Retrieve the current GPS position with settings and timeouts unified.
  Future<Position?> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Tries to resolve location automatically from GPS.
  /// Returns [true] if coordinates are cached/set successfully.
  Future<bool> tryAutoResolveLocation() async {
    if (_appData.location != null) return true;

    try {
      final hasPerm = await hasLocationPermission();
      if (!hasPerm) return false;

      final position = await determinePosition();
      if (position == null) return false;

      final placeName = await _getPlaceName(
        position.latitude,
        position.longitude,
      );
      await saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: placeName,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<LatLng?> saveLocation({
    required double latitude,
    required double longitude,
    String? placeName,
    bool syncProfile = true,
  }) async {
    if (!latitude.isFinite || !longitude.isFinite) {
      debugPrint(
        'Warning: Attempted to save non-finite location: LatLng($latitude, $longitude)',
      );
      return null;
    }
    try {
      final resolvedName =
          placeName ?? await _getPlaceName(latitude, longitude);

      await _appData.setLocation(latitude, longitude, placeName: resolvedName);

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
      final placeMarks = await placemarkFromCoordinates(lat, lon);
      if (placeMarks.isEmpty) return null;

      final place = placeMarks.first;
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
