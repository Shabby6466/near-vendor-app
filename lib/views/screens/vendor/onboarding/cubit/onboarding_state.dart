part of 'onboarding_cubit.dart';

enum OnboardingStep { businessInfo, locationContact, verification }

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final String businessName;
  final String category;
  final String taxId;
  final String phoneNumber;
  final String cnicNo;
  final String? cnicImagePath;
  final List<CategoryModel> availableCategories;
  final bool termsAccepted;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isUploadingImage;
  final bool isLoadingCategories;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = OnboardingStep.businessInfo,
    this.businessName = '',
    this.category = '',
    this.taxId = '',
    this.phoneNumber = '',
    this.cnicNo = '',
    this.cnicImagePath,
    this.availableCategories = const [],
    this.termsAccepted = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isUploadingImage = false,
    this.isLoadingCategories = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        currentStep,
        businessName,
        category,
        taxId,
        phoneNumber,
        cnicNo,
        cnicImagePath,
        availableCategories,
        termsAccepted,
        isSubmitting,
        isSuccess,
        isUploadingImage,
        isLoadingCategories,
        errorMessage,
      ];

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? businessName,
    String? category,
    String? taxId,
    String? phoneNumber,
    String? cnicNo,
    String? cnicImagePath,
    List<CategoryModel>? availableCategories,
    bool? termsAccepted,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isUploadingImage,
    bool? isLoadingCategories,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      taxId: taxId ?? this.taxId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cnicNo: cnicNo ?? this.cnicNo,
      cnicImagePath: cnicImagePath ?? this.cnicImagePath,
      availableCategories: availableCategories ?? this.availableCategories,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get canMoveToNext {
    switch (currentStep) {
      case OnboardingStep.businessInfo:
        return businessName.isNotEmpty && category.isNotEmpty;
      case OnboardingStep.locationContact:
        return phoneNumber.isNotEmpty && taxId.isNotEmpty && cnicNo.isNotEmpty;
      case OnboardingStep.verification:
        return cnicImagePath != null && cnicImagePath!.isNotEmpty && termsAccepted;
    }
  }
}
