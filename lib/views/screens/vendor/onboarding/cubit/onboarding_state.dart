part of 'onboarding_cubit.dart';

enum OnboardingStep { businessInfo, locationContact, verification }

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final String businessName;
  final String category;
  final String address;
  final String phoneNumber;
  final String email;
  final String cnicNo;
  final String? storeImagePath;
  final bool termsAccepted;
  final bool isSubmitting;
  final bool isSuccess;

  const OnboardingState({
    this.currentStep = OnboardingStep.businessInfo,
    this.businessName = '',
    this.category = '',
    this.address = '',
    this.phoneNumber = '',
    this.email = '',
    this.cnicNo = '',
    this.storeImagePath,
    this.termsAccepted = false,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
        currentStep,
        businessName,
        category,
        address,
        phoneNumber,
        email,
        cnicNo,
        storeImagePath,
        termsAccepted,
        isSubmitting,
        isSuccess,
      ];

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? businessName,
    String? category,
    String? address,
    String? phoneNumber,
    String? email,
    String? cnicNo,
    String? storeImagePath,
    bool? termsAccepted,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      cnicNo: cnicNo ?? this.cnicNo,
      storeImagePath: storeImagePath ?? this.storeImagePath,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
