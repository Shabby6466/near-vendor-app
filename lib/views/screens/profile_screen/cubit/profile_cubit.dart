import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ReviewServices _reviewServices = ReviewServices();

  ProfileCubit() : super(ProfileInitial()) {
    _loadProfile();
    // Listen to AppData user and location changes
    AppData().userNotifier.addListener(_onProfileChanged);
    AppData().locationNotifier.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (state is ProfileSuccess) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    emit(ProfileLoading());
    final user = AppData().currentUser;
    final radius = CurrentUserStorage.getDiscoveryRadius();
    final locationName =
        AppData().locationNotifier.value?.displayLabel ?? 'Location not set';

    emit(
      ProfileSuccess(
        userName: user?.fullName ?? 'Guest User',
        userLocation: locationName,
        photoUrl: user?.photoUrl,
        discoveryRadius: radius,
        newOfferAlerts: true,
      ),
    );
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

  /// Toggles review comment notifications silently in the background.
  /// UI updates optimistically — no loading state.
  void toggleReviewNotifications(bool value) {
    final currentState = state;
    if (currentState is ProfileSuccess) {
      emit(currentState.copyWith(reviewNotifications: value));
      _reviewServices.toggleReviewNotifications(value);
    }
  }

  /// Updates the user's profile on the server and refreshes AppData.
  /// Moved here from SessionCubit (Priority 8b.1 / 5.2).
  Future<void> updateUserProfile(UpdateUserInput input) async {
    try {
      final response = await AuthServices().updateUser(input);
      if (response.isSuccess) {
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
          // _onProfileChanged listener will reload the profile state automatically
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  Future<String?> _getCityName(double lat, double lon) async {
    try {
      final placeMarks = await placemarkFromCoordinates(lat, lon);
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
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
    // Remove listeners
    AppData().userNotifier.removeListener(_onProfileChanged);
    AppData().locationNotifier.removeListener(_onProfileChanged);
    await super.close();
  }
}
