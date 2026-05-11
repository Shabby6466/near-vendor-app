import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/services/media_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ImagePicker _picker = ImagePicker();

  ProfileCubit() : super(ProfileInitial()) {
    _loadProfile();
    // Listen to AppData user changes
    AppData().userNotifier.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    if (state is ProfileSuccess) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    emit(ProfileLoading());
    final user = AppData().currentUser;
    final radius = CurrentUserStorage.getDiscoveryRadius();

    emit(
      ProfileSuccess(
        userName: user?.fullName ?? 'Guest User',
        userLocation: user?.cityName ?? 'Location not set',
        photoUrl: user?.photoUrl,
        discoveryRadius: radius,
        newOfferAlerts: true,
      ),
    );
  }

  Future<void> pickImageFromGallery() async {
    final currentState = state;
    if (currentState is! ProfileSuccess) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(currentState.copyWith(isUploadingImage: true));
        final String? uploadedUrl = await MediaServices.uploadImage(
          File(image.path),
        );
        if (uploadedUrl != null) {
          // Emit state change - AppData will be updated when profile reloads
          emit(
            currentState.copyWith(
              photoUrl: uploadedUrl,
              isUploadingImage: false,
            ),
          );
        } else {
          emit(currentState.copyWith(isUploadingImage: false));
        }
      }
    } catch (e) {
      if (state is ProfileSuccess) {
        emit((state as ProfileSuccess).copyWith(isUploadingImage: false));
      }
    }
  }

  Future<void> updateRadius(double radius) async {
    final currentState = state;
    if (currentState is ProfileSuccess) {
      await CurrentUserStorage.setDiscoveryRadius(radius);
      // Update AppData
      await AppData().setDiscoveryRadius(radius);
      emit(currentState.copyWith(discoveryRadius: radius));
    }
  }

  void toggleOfferAlerts(bool value) {
    final currentState = state;
    if (currentState is ProfileSuccess) {
      emit(currentState.copyWith(newOfferAlerts: value));
    }
  }

  /// Updates the user's profile on the server and refreshes AppData.
  /// Moved here from SessionCubit (Priority 8b.1 / 5.2).
  Future<void> updateUserProfile(UpdateUserInput input) async {
    try {
      final response = await AuthServices().updateUser(input);
      if (response.status == 200 || response.status == 201) {
        final meResponse = await AuthServices().getMe();
        if (meResponse.user != null) {
          String? cityName;
          if (meResponse.user?.lastKnownLatitude != null &&
              meResponse.user?.lastKnownLongitude != null) {
            cityName = await _getCityName(
              meResponse.user!.lastKnownLatitude!,
              meResponse.user!.lastKnownLongitude!,
            );
            if (cityName != null) {
              meResponse.user = meResponse.user!.copyWith(cityName: cityName);
            }
          }
          await CurrentUserStorage.storeUserData(meResponse.user);
          AppData().updateUser(meResponse.user!);
          // _onUserChanged listener will reload the profile state automatically
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

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

  @override
  Future<void> close() async {
    // Remove listener
    AppData().userNotifier.removeListener(_onUserChanged);
    await super.close();
  }
}
