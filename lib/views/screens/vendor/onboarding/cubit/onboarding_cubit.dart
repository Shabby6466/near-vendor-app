import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final ImagePicker _picker = ImagePicker();

  OnboardingCubit() : super(const OnboardingState());

  void updateBusinessInfo({String? name, String? category, String? description}) {
    emit(state.copyWith(
      businessName: name,
      category: category,
      description: description,
    ));
  }

  void updateLocationContact({String? address, String? phone, String? email}) {
    emit(state.copyWith(
      address: address,
      phoneNumber: phone,
      email: email,
    ));
  }

  Future<void> pickStoreImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      emit(state.copyWith(storeImagePath: image.path));
    }
  }

  void toggleTerms(bool? value) {
    emit(state.copyWith(termsAccepted: value ?? false));
  }

  void nextStep() {
    if (state.currentStep == OnboardingStep.businessInfo) {
      emit(state.copyWith(currentStep: OnboardingStep.locationContact));
    } else if (state.currentStep == OnboardingStep.locationContact) {
      emit(state.copyWith(currentStep: OnboardingStep.verification));
    }
  }

  void previousStep() {
    if (state.currentStep == OnboardingStep.locationContact) {
      emit(state.copyWith(currentStep: OnboardingStep.businessInfo));
    } else if (state.currentStep == OnboardingStep.verification) {
      emit(state.copyWith(currentStep: OnboardingStep.locationContact));
    }
  }

  Future<void> launchStore() async {
    emit(state.copyWith(isSubmitting: true));
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }
}
