import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final ImagePicker _picker = ImagePicker();

  OnboardingCubit() : super(const OnboardingState());

  void updateBusinessInfo({String? name, String? category}) {
    emit(state.copyWith(
      businessName: name,
      category: category,
    ));
  }

  void updateLocationContact({String? address, String? phone, String? email, String? cnic, String? taxId}) {
    emit(state.copyWith(
      address: address,
      phoneNumber: phone,
      email: email,
      cnicNo: cnic,
      taxId: taxId,
    ));
  }

  Future<void> pickCnicImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      emit(state.copyWith(cnicImagePath: image.path));
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

    final input = RegisterInput(
      businessName: state.businessName,
      businessCategory: state.category,
      taxId: state.taxId,
      supportContact: state.phoneNumber,
      cnic: state.cnicNo,
      cnicImageUrl: state.cnicImagePath ?? '', // Placeholder or local path
    );

    try {
      final response = await AuthServices().register(input);
      debugPrint('Registration Status: ${response.status}');
      debugPrint('Registration Message: ${response.message}');
      
      if (response.status == 200 || response.status == 201) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        emit(state.copyWith(isSubmitting: false));
        // Handle error (e.g., show snackbar)
        debugPrint('Registration failed with status ${response.status}: ${response.message}');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
