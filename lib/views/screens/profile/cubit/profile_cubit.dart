import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ImagePicker _picker = ImagePicker();

  ProfileCubit() : super(ProfileInitial()) {
    _loadProfile();
  }

  void _loadProfile() {
    emit(ProfileLoading());
    // Simulate loading data from a repository or local storage
    // In a real app, this would come from a User repository
    emit(const ProfileSuccess(
      userName: 'Elena Rodriguez',
      userLocation: 'Brooklyn, New York',
      profileImagePath: null, // Initially no custom image
      discoveryRadius: 5.0,
      newOfferAlerts: true,
    ));
  }

  Future<void> pickImageFromGallery() async {
    final currentState = state;
    if (currentState is! ProfileSuccess) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(currentState.copyWith(profileImagePath: image.path));
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  void updateRadius(double radius) {
    final currentState = state;
    if (currentState is ProfileSuccess) {
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
