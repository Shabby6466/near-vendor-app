import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/vendor_dashboard_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/cubit/onboarding_cubit.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/widgets/business_info_step.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/widgets/location_contact_step.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/widgets/step_progress_indicator.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/widgets/verification_launch_step.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(OnboardingStep step) {
    int page = 0;
    switch (step) {
      case OnboardingStep.businessInfo:
        page = 0;
        break;
      case OnboardingStep.locationContact:
        page = 1;
        break;
      case OnboardingStep.verification:
        page = 2;
        break;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<OnboardingCubit, OnboardingState>(
            listenWhen: (p, c) => p.currentStep != c.currentStep,
            listener: (context, state) => _onStepChanged(state.currentStep),
          ),
          BlocListener<OnboardingCubit, OnboardingState>(
            listenWhen: (p, c) => !p.isSuccess && c.isSuccess,
            listener: (context, state) {
              AppNavigator.pushReplacement(context, const VendorDashboardScreen());
            },
          ),
        ],
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (state.currentStep == OnboardingStep.businessInfo) {
                      AppNavigator.pop(context);
                    } else {
                      context.read<OnboardingCubit>().previousStep();
                    }
                  },
                ),
                title: Text(
                  'Vendor Onboarding',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: StepProgressIndicator(
                        currentStep: _getStepNumber(state.currentStep),
                        totalSteps: 3,
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          BusinessInfoStep(),
                          LocationContactStep(),
                          VerificationLaunchStep(),
                        ],
                      ),
                    ),
                    _buildFooter(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _getStepNumber(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.businessInfo:
        return 1;
      case OnboardingStep.locationContact:
        return 2;
      case OnboardingStep.verification:
        return 3;
    }
  }

  Widget _buildFooter(BuildContext context, OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (state.currentStep != OnboardingStep.businessInfo) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => context.read<OnboardingCubit>().previousStep(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: AppElevatedButton(
              isEnabled: state.currentStep == OnboardingStep.verification ? state.termsAccepted : true,
              onPressed: () {
                if (state.currentStep == OnboardingStep.verification) {
                  context.read<OnboardingCubit>().launchStore();
                } else {
                  context.read<OnboardingCubit>().nextStep();
                }
              },
              text: state.currentStep == OnboardingStep.verification ? 'Launch My Store' : 'Next Step →',
            ),
          ),
        ],
      ),
    );
  }
}
