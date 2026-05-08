import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  Future<void> initialize() async {
    final token = CurrentUserStorage.getUserAuthToken();
    final user = CurrentUserStorage.getCurrentUser();
    final hasOnboarded = CurrentUserStorage.getHasOnboarded();

    if (token != null) {
      if (user != null) {
        String? cityName = user.cityName;
        if (cityName == null &&
            user.lastKnownLatitude != null &&
            user.lastKnownLongitude != null) {
          cityName = await _getCityName(
            user.lastKnownLatitude!,
            user.lastKnownLongitude!,
          );
          if (cityName != null) {
            user.cityName = cityName;
            await CurrentUserStorage.storeUserData(user);
          }
        }

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            userName: user.fullName,
            hasOnboarded: hasOnboarded,
            photoUrl: user.photoUrl,
            latitude: user.lastKnownLatitude,
            longitude: user.lastKnownLongitude,
            cityName: cityName,
          ),
        );
      }

      try {
        final response = await AuthServices().getMe();
        if (response.user != null) {
          String? cityName;
          if (response.user?.lastKnownLatitude != null &&
              response.user?.lastKnownLongitude != null) {
            cityName = await _getCityName(
              response.user!.lastKnownLatitude!,
              response.user!.lastKnownLongitude!,
            );
            if (cityName == null &&
                response.user!.lastKnownLatitude!.toStringAsFixed(3) ==
                    "37.422" &&
                response.user!.lastKnownLongitude!.toStringAsFixed(3) ==
                    "-122.084") {
              cityName = "Mountain View";
            }
            response.user!.cityName = cityName;
          }
          await CurrentUserStorage.storeUserData(response.user);
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: response.user,
              userName: response.user?.fullName,
              hasOnboarded: hasOnboarded,
              photoUrl: response.user?.photoUrl,
              latitude: response.user?.lastKnownLatitude,
              longitude: response.user?.lastKnownLongitude,
              cityName: cityName,
            ),
          );
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint('Session refresh failed: $e');
        await logout();
      }
    } else {
      // Fallback for Guest location from storage
      final lastLoc = CurrentUserStorage.getLastLocation();
      emit(
        state.copyWith(
          status: AuthStatus.guest,
          userName: 'Guest User',
          hasOnboarded: hasOnboarded,
          latitude: lastLoc?['lat'],
          longitude: lastLoc?['lon'],
        ),
      );
    }
  }

  void setAuthenticated(User? user) {
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        userName: user?.fullName,
        photoUrl: user?.photoUrl,
        latitude: user?.lastKnownLatitude,
        longitude: user?.lastKnownLongitude,
        cityName: user?.cityName,
      ),
    );
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> logout() async {
    await CurrentUserStorage.clearUserData();
    emit(const SessionState(status: AuthStatus.guest, userName: 'Guest User'));
  }

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

      // Clear temp location before updating manual location
      emit(state.copyWith(clearTempLocation: true));

      await updateManualLocation(latitude: lat, longitude: lng);
    }
  }

  void cancelManualLocationPick() {
    emit(state.copyWith(clearTempLocation: true));
  }

  void setOnboarded() {
    CurrentUserStorage.setHasOnboarded(true);
    emit(state.copyWith(hasOnboarded: true));
  }

  Future<void> updateUserProfile(UpdateUserInput input) async {
    try {
      final response = await AuthServices().updateUser(input);
      if (response.status == 200 || response.status == 201) {
        // Refresh user data from server to stay in sync
        final meResponse = await AuthServices().getMe();
        if (meResponse.user != null) {
          String? cityName;
          if (meResponse.user?.lastKnownLatitude != null &&
              meResponse.user?.lastKnownLongitude != null) {
            cityName = await _getCityName(
              meResponse.user!.lastKnownLatitude!,
              meResponse.user!.lastKnownLongitude!,
            );
            if (cityName == null &&
                meResponse.user!.lastKnownLatitude!.toStringAsFixed(3) ==
                    "37.422" &&
                meResponse.user!.lastKnownLongitude!.toStringAsFixed(3) ==
                    "-122.084") {
              cityName = "Mountain View";
            }
            meResponse.user!.cityName = cityName;
          }
          await CurrentUserStorage.storeUserData(meResponse.user);
          emit(
            state.copyWith(
              user: meResponse.user,
              userName: meResponse.user?.fullName,
              photoUrl: meResponse.user?.photoUrl,
              latitude: meResponse.user?.lastKnownLatitude,
              longitude: meResponse.user?.lastKnownLongitude,
              cityName: cityName,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  Future<void> updateManualLocation({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    try {
      // Persist location locally
      await CurrentUserStorage.setLastLocation(latitude, longitude);

      String? finalCityName = cityName;
      if (finalCityName == null) {
        finalCityName = await _getCityName(latitude, longitude);
        // Fallback for emulator if geocoding fails
        if (finalCityName == null &&
            latitude.toStringAsFixed(3) == "37.422" &&
            longitude.toStringAsFixed(3) == "-122.084") {
          finalCityName = "Mountain View";
        }
      }

      if (isAuthenticated) {
        await updateUserProfile(
          UpdateUserInput(latitude: latitude, longitude: longitude),
        );
      }

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

  Future<void> updateLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Persist location locally
      await CurrentUserStorage.setLastLocation(
        position.latitude,
        position.longitude,
      );

      final String? cityName = await _getCityName(
        position.latitude,
        position.longitude,
      );

      if (isAuthenticated) {
        await updateUserProfile(
          UpdateUserInput(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }

      // The updateUserProfile will call emit if authenticated,
      // but for guests we still want to update the local state with the city name etc.
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

  Future<String?> _getCityName(double lat, double lon) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final city =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
        final country = place.country;
        if (city != null && country != null) {
          return "$city, $country";
        }
        return city;
      }
    } catch (e) {
      debugPrint('Error getting city name: $e');
    }
    return "Unknown Location";
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
