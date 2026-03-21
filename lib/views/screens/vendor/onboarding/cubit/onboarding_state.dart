part of 'onboarding_cubit.dart';

enum OnboardingStep { businessInfo, locationContact, verification }

class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final String businessName;
  final String category;
  final String description;
  final String address;
  final String phoneNumber;
  final String email;
  final String? storeImagePath;
  final bool termsAccepted;
  final bool isSubmitting;
  final bool isSuccess;

  const OnboardingState({
    this.currentStep = OnboardingStep.businessInfo,
    this.businessName = '',
    this.category = '',
    this.description = '',
    this.address = '',
    this.phoneNumber = '',
    this.email = '',
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
        description,
        address,
        phoneNumber,
        email,
        storeImagePath,
        termsAccepted,
        isSubmitting,
        isSuccess,
      ];

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? businessName,
    String? category,
    String? description,
    String? address,
    String? phoneNumber,
    String? email,
    String? storeImagePath,
    bool? termsAccepted,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      storeImagePath: storeImagePath ?? this.storeImagePath,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
