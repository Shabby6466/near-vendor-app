import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';

class AppLocationService {
  AppLocationService._();

  static final AppLocationService instance = AppLocationService._();

  final AuthServices _authServices = AuthServices();
  final AppData _appData = AppData();

  Future<void> checkAndPromptLocation(BuildContext context) async {
    // If location is already set in memory/cache, do nothing
    if (_appData.location != null) return;

    try {
      final permission = await Geolocator.checkPermission();
      final hasPermission = permission == LocationPermission.always ||
                            permission == LocationPermission.whileInUse;

      // If we do not have permission, show the bottom sheet prompt
      if (!hasPermission) {
        if (context.mounted) {
          await AppBottomSheet.showLocationPermissionPrompt(context);
        }
        return;
      }

      // If we have permission, update location automatically from GPS (with 5s timeout)
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
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
      debugPrint('Error checking or updating location: $e');
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
