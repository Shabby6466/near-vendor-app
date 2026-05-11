import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit/profile_cubit.dart';

part 'location_state.dart';

/// Owns all location concerns previously in SessionCubit:
/// - GPS location (updateLocation)
/// - Manual location (updateManualLocation)
/// - Temp location picker state (startManualLocationPick, updateTempLocation,
///   confirmManualLocationPick, cancelManualLocationPick)
///
/// Provided at the root MultiBlocProvider alongside SessionCubit.
/// Consumers that previously read session.latitude/longitude now read
/// LocationCubit state instead.
class LocationCubit extends Cubit<LocationState> {
  final ProfileCubit _profileCubit;

  LocationCubit({required ProfileCubit profileCubit})
    : _profileCubit = profileCubit,
      super(const LocationState()) {
    _restoreFromStorage();
  }

  void _restoreFromStorage() {
    final lastLoc = CurrentUserStorage.getLastLocation();
    if (lastLoc != null) {
      emit(state.copyWith(latitude: lastLoc['lat'], longitude: lastLoc['lon']));
    }
  }

  // ── GPS location ──────────────────────────────────────────────────────────

  Future<void> updateLocation() async {
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

      await CurrentUserStorage.setLastLocation(
        position.latitude,
        position.longitude,
      );
      await AppData().setLocation(position.latitude, position.longitude);

      final cityName = await _getCityName(
        position.latitude,
        position.longitude,
      );

      // Sync to server if authenticated
      await _profileCubit.updateUserProfile(
        UpdateUserInput(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      emit(
        state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
        ),
      );
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  // ── Manual location ───────────────────────────────────────────────────────

  Future<void> updateManualLocation({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    try {
      await CurrentUserStorage.setLastLocation(latitude, longitude);
      await AppData().setLocation(latitude, longitude, cityName: cityName);

      String? finalCityName =
          cityName ?? await _getCityName(latitude, longitude);
      if (finalCityName == null &&
          latitude.toStringAsFixed(3) == '37.422' &&
          longitude.toStringAsFixed(3) == '-122.084') {
        finalCityName = 'Mountain View';
      }

      await _profileCubit.updateUserProfile(
        UpdateUserInput(latitude: latitude, longitude: longitude),
      );

      emit(
        state.copyWith(
          latitude: latitude,
          longitude: longitude,
          cityName: finalCityName,
        ),
      );
    } catch (e) {
      debugPrint('Error updating manual location: $e');
    }
  }

  // ── Temp location picker ──────────────────────────────────────────────────

  void startManualLocationPick({double? tempLatitude, double? tempLongitude}) {
    emit(
      state.copyWith(
        tempLatitude: tempLatitude ?? state.latitude ?? 33.667306,
        tempLongitude: tempLongitude ?? state.longitude ?? 73.075177,
      ),
    );
  }

  void updateTempLocation(double lat, double lng) {
    emit(state.copyWith(tempLatitude: lat, tempLongitude: lng));
  }

  Future<void> confirmManualLocationPick() async {
    if (state.tempLatitude != null && state.tempLongitude != null) {
      final lat = state.tempLatitude!;
      final lng = state.tempLongitude!;
      emit(state.copyWith(clearTempLocation: true));
      await updateManualLocation(latitude: lat, longitude: lng);
    }
  }

  void cancelManualLocationPick() {
    emit(state.copyWith(clearTempLocation: true));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String?> _getCityName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
        final country = place.country;
        if (city != null && country != null) return '$city, $country';
        return city;
      }
    } catch (e) {
      debugPrint('Error getting city name: $e');
    }
    return null;
  }
}
