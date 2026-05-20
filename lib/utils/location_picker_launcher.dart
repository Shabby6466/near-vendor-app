import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';

/// Opens the location picker and returns the confirmed [AppLocation], or null if cancelled.
class LocationPickerLauncher {
  LocationPickerLauncher._();

  static Future<AppLocation?> open(BuildContext context) async {
    final existing = AppData().location;
    final result = await AppNavigator.push(
      context,
      LocationPickerScreen(initialLocation: existing?.toLatLng()),
    );
    if (result is LatLng) {
      return AppData().location ??
          AppLocation(
            latitude: result.latitude,
            longitude: result.longitude,
          );
    }
    return AppData().location;
  }

  /// Returns saved location or opens the picker when [required] and none is set.
  static Future<AppLocation?> ensureLocation(
    BuildContext context, {
    bool required = true,
  }) async {
    final existing = AppData().location;
    if (existing != null) return existing;
    if (!required) return null;
    return open(context);
  }
}
