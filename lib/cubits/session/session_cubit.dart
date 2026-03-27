import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void initialize() async {
    final token = CurrentUserStorage.getUserAuthToken();
    final user = CurrentUserStorage.getCurrentUser();
    final hasOnboarded = CurrentUserStorage.getHasOnboarded();

    if (token != null) {
      if (user != null) {
        String? cityName = user.cityName;
        if (cityName == null && user.lastKnownLatitude != null && user.lastKnownLongitude != null) {
          cityName = await _getCityName(user.lastKnownLatitude!, user.lastKnownLongitude!);
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
            isVendor: user.role?.toUpperCase() == 'VENDOR',
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
          String? vendorStatus;
          final statusResponse = await AuthServices().getVendorStatus();
          if (statusResponse.vendorStatus != null) {
            vendorStatus = statusResponse.vendorStatus;
          } else if (response.user?.role?.toUpperCase() == 'VENDOR') {
            vendorStatus = 'APPROVED';
          }
          final bool isVendor = (response.user?.role?.toUpperCase() == 'VENDOR') || (statusResponse.vendorStatus != null);

          String? cityName;
          if (response.user?.lastKnownLatitude != null && response.user?.lastKnownLongitude != null) {
            cityName = await _getCityName(response.user!.lastKnownLatitude!, response.user!.lastKnownLongitude!);
            if (cityName == null && response.user!.lastKnownLatitude!.toStringAsFixed(3) == "37.422" && response.user!.lastKnownLongitude!.toStringAsFixed(3) == "-122.084") {
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
              isVendor: isVendor,
              hasOnboarded: hasOnboarded,
              photoUrl: response.user?.photoUrl,
              latitude: response.user?.lastKnownLatitude,
              longitude: response.user?.lastKnownLongitude,
              cityName: cityName,
              vendorStatus: vendorStatus,
            ),
          );
        }
      } catch (e) {
        debugPrint('Session refresh failed: $e');
      }
    } else {
      emit(state.copyWith(
        status: AuthStatus.guest,
        userName: 'Guest User',
        hasOnboarded: hasOnboarded,
      ));
    }
  }

  void setAuthenticated(User? user) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      userName: user?.fullName,
      isVendor: user?.role?.toUpperCase() == 'VENDOR',
      photoUrl: user?.photoUrl,
      latitude: user?.lastKnownLatitude,
      longitude: user?.lastKnownLongitude,
      cityName: user?.cityName,
    ));
  }

  void setGuest() {
    emit(state.copyWith(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> logout() async {
    await CurrentUserStorage.clearUserData();
    emit(const SessionState(status: AuthStatus.guest, userName: 'Guest User'));
  }

  Future<void> refreshVendorStatus() async {
    if (state.isVendor) {
      final response = await AuthServices().getVendorStatus();
      if (response.vendorStatus != null) {
        emit(state.copyWith(vendorStatus: response.vendorStatus));
      } else {
        emit(state.copyWith(vendorStatus: 'PENDING'));
      }
    }
  }

  void setVendorStatus(bool isVendor) {
    if (state.user != null) {
      state.user!.role = isVendor ? 'VENDOR' : 'USER';
      CurrentUserStorage.storeUserData(state.user!);
    }
    emit(state.copyWith(isVendor: isVendor, clearVendorStatus: isVendor));
    if (isVendor) {
      refreshVendorStatus();
    }
  }

  void setOnboarded() {
    CurrentUserStorage.setHasOnboarded(true);
    emit(state.copyWith(hasOnboarded: true));
  }

  Future<void> updateUserProfile(UpdateUserInput input) async {
    try {
      final response = await AuthServices().updateUser(input);
      if (response.status == true) {
        // Refresh user data from server to stay in sync
        final meResponse = await AuthServices().getMe();
        if (meResponse.user != null) {
          String? cityName;
          if (meResponse.user?.lastKnownLatitude != null && meResponse.user?.lastKnownLongitude != null) {
            cityName = await _getCityName(meResponse.user!.lastKnownLatitude!, meResponse.user!.lastKnownLongitude!);
            if (cityName == null && meResponse.user!.lastKnownLatitude!.toStringAsFixed(3) == "37.422" && meResponse.user!.lastKnownLongitude!.toStringAsFixed(3) == "-122.084") {
              cityName = "Mountain View";
            }
            meResponse.user!.cityName = cityName;
          }
          await CurrentUserStorage.storeUserData(meResponse.user);
          emit(state.copyWith(
            user: meResponse.user,
            userName: meResponse.user?.fullName,
            isVendor: meResponse.user?.role?.toUpperCase() == 'VENDOR',
            photoUrl: meResponse.user?.photoUrl,
            latitude: meResponse.user?.lastKnownLatitude,
            longitude: meResponse.user?.lastKnownLongitude,
            cityName: cityName,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      String? cityName = await _getCityName(position.latitude, position.longitude);
      
      // Fallback for emulator if geocoding fails
      if (cityName == null && position.latitude.toStringAsFixed(3) == "37.422" && position.longitude.toStringAsFixed(3) == "-122.084") {
        cityName = "Mountain View";
      }

      await updateUserProfile(UpdateUserInput(
        latitude: position.latitude,
        longitude: position.longitude,
      ));

      // The updateUserProfile will call emit, but let's ensure cityName is correct in the final state
      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      ));
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<String?> _getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      }
    } catch (e) {
      debugPrint('Error getting city name: $e');
    }
    return null;
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}
