import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/models/data_models/category_model.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/services/categories_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final ImagePicker _picker = ImagePicker();

  OnboardingCubit() : super(const OnboardingState()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    emit(state.copyWith(isLoadingCategories: true, errorMessage: null));
    try {
      final categories = await CategoriesService.getCategories();
      emit(state.copyWith(
        availableCategories: categories,
        isLoadingCategories: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingCategories: false,
        errorMessage: 'Failed to load categories: $e',
      ));
    }
  }

  void updateBusinessInfo({String? name, String? category}) {
    emit(state.copyWith(businessName: name, category: category));
  }

  void updateLegalContact({
    String? phone,
    String? cnic,
    String? taxId,
  }) {
    emit(
      state.copyWith(
        phoneNumber: phone,
        cnicNo: cnic,
        taxId: taxId,
      ),
    );
  }

  Future<void> pickCnicImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      emit(state.copyWith(cnicImagePath: image.path, isUploadingImage: true));
      
      try {
        final uploadResponse = await AuthServices().uploadMedia(image.path);
        // Check for common success codes or if a URL was returned (indicating success)
        if (uploadResponse.status == 200 || 
            uploadResponse.status == 201 || 
            (uploadResponse.url != null && uploadResponse.url!.isNotEmpty)) {
          emit(state.copyWith(
            cnicImagePath: uploadResponse.url ?? image.path,
            isUploadingImage: false,
          ));
          debugPrint('Image uploaded successfully: ${uploadResponse.url}');
        } else {
          emit(state.copyWith(
            isUploadingImage: false,
            errorMessage: 'Upload failed (${uploadResponse.status}): ${uploadResponse.message}',
          ));
        }
      } catch (e) {
        emit(state.copyWith(isUploadingImage: false, errorMessage: e.toString()));
      }
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
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // 2. Register Vendor
      final input = RegisterInput(
        businessName: state.businessName,
        businessCategory: state.category,
        taxId: state.taxId,
        supportContact: state.phoneNumber,
        cnic: state.cnicNo,
        cnicImageUrl: state.cnicImagePath ?? '',
      );

      debugPrint('Hitting Register API with input: ${input.toJson()}');
      final response = await AuthServices().registerVendor(input);
      debugPrint('Registration Status: ${response.status}');
      debugPrint('Registration Message: ${response.message}');

      if (response.status == 200 || 
          response.status == 201 || 
          (response.message?.toLowerCase().contains('already exists') ?? false)) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: response.message ?? 'Registration failed',
        ));
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
