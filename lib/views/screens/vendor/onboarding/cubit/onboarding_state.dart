part of 'onboarding_cubit.dart';

enum OnboardingStep { businessInfo, locationContact, verification }

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final String businessName;
  final String category;
  final String taxId;
  final String address;
  final String phoneNumber;
  final String email;
  final String cnicNo;
  final String? cnicImagePath;
  final bool termsAccepted;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isUploadingImage;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = OnboardingStep.businessInfo,
    this.businessName = '',
    this.category = '',
    this.taxId = '',
    this.address = '',
    this.phoneNumber = '',
    this.email = '',
    this.cnicNo = '',
    this.cnicImagePath,
    this.termsAccepted = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        currentStep,
        businessName,
        category,
        taxId,
        address,
        phoneNumber,
        email,
        cnicNo,
        cnicImagePath,
        termsAccepted,
        isSubmitting,
        isSuccess,
        isUploadingImage,
        errorMessage,
      ];

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? businessName,
    String? category,
    String? taxId,
    String? address,
    String? phoneNumber,
    String? email,
    String? cnicNo,
    String? cnicImagePath,
    bool? termsAccepted,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isUploadingImage,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      taxId: taxId ?? this.taxId,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      cnicNo: cnicNo ?? this.cnicNo,
      cnicImagePath: cnicImagePath ?? this.cnicImagePath,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
