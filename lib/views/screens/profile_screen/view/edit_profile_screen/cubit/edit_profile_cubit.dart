import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/api_request_models/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/services/media_services.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/edit_profile_screen/cubit/edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final ImagePicker _picker = ImagePicker();

  EditProfileCubit()
    : super(EditProfileState(photoUrl: AppData().currentUser?.photoUrl));

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(
    text: AppData().currentUser?.fullName ?? '',
  );

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        emit(
          state.copyWith(
            pickedImage: File(image.path),
            status: EditProfileStatus.initial,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: 'Failed to pick image: $e',
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    final newFullName = nameController.text.trim();

    if (newFullName.isEmpty) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: 'Full name cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditProfileStatus.submitting));

    try {
      String? updatedPhotoUrl = state.photoUrl;

      // 1. If user selected a new local image, upload it first
      if (state.pickedImage != null) {
        final uploadResponse = await MediaServices.uploadImage(
          state.pickedImage!,
        );
        if (uploadResponse.isSuccess) {
          updatedPhotoUrl = uploadResponse.url;
          if (updatedPhotoUrl == null) {
            emit(
              state.copyWith(
                status: EditProfileStatus.failure,
                errorMessage: 'Failed to upload profile image: URL missing',
              ),
            );
            return;
          }
        } else {
          emit(
            state.copyWith(
              status: EditProfileStatus.failure,
              errorMessage:
                  uploadResponse.message ?? 'Failed to upload profile image',
            ),
          );
          return;
        }
      }

      // 2. Call backend update profile API
      final updateInput = UpdateUserInput(
        fullName: newFullName,
        photoUrl: updatedPhotoUrl,
      );

      final response = await AuthServices().updateUser(updateInput);
      if (response.isSuccess) {
        // Fetch fresh user data to update the local cache
        final meResponse = await AuthServices().getMe();
        if (meResponse.user != null) {
          final user = meResponse.user!;

          // Update Hive and AppData
          await CurrentUserStorage.storeUserData(user);
          AppData().updateUser(user);

          emit(
            state.copyWith(
              photoUrl: user.photoUrl,
              status: EditProfileStatus.success,
              clearImage: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: EditProfileStatus.failure,
              errorMessage: 'Failed to retrieve updated user details',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: EditProfileStatus.failure,
            errorMessage: response.message ?? 'Failed to update profile',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }
}
