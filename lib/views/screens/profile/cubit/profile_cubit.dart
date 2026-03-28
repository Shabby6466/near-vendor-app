import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/media_services.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';

part 'profile_state.dart';


class ProfileCubit extends Cubit<ProfileState> {
  final ImagePicker _picker = ImagePicker();
  final SessionCubit sessionCubit;

  ProfileCubit(this.sessionCubit) : super(ProfileInitial()) {
    _loadProfile();
  }

  void _loadProfile() {
    emit(ProfileLoading());
    final user = CurrentUserStorage.getCurrentUser();
    final radius = CurrentUserStorage.getDiscoveryRadius();
    
    emit(ProfileSuccess(
      userName: user?.fullName ?? 'Guest User',
      userLocation: user?.email ?? 'No email provided',
      photoUrl: user?.photoUrl,
      discoveryRadius: radius,
      newOfferAlerts: true,
    ));
  }

  Future<void> pickImageFromGallery() async {
    final currentState = state;
    if (currentState is! ProfileSuccess) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // 1. Set uploading state
        emit(currentState.copyWith(isUploadingImage: true));
        // 2. Upload image
        final String? uploadedUrl = await MediaServices.uploadImage(File(image.path));
        if (uploadedUrl != null) {
          // 3. Update profile
          await sessionCubit.updateUserProfile(UpdateUserInput(photoUrl: uploadedUrl));
          // 4. Update local state
          emit(currentState.copyWith(photoUrl: uploadedUrl, isUploadingImage: false));
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
      emit(currentState.copyWith(discoveryRadius: radius));
    }
  }

  void toggleOfferAlerts(bool value) {
    final currentState = state;
    if (currentState is ProfileSuccess) {
      emit(currentState.copyWith(newOfferAlerts: value));
    }
  }
}
