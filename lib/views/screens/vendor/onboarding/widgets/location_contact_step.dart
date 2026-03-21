import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/cubit/onboarding_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class LocationContactStep extends StatelessWidget {
  const LocationContactStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location & Contact',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pin your business location and provide contact details so customers can find you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          'Tap and hold the pin to adjust your location',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Business Address'),
              AppTextField(
                hint: '123 Commerce St, Suite 101',
                prefixIcon: const Icon(Icons.home_outlined),
                onChanged: (val) => context.read<OnboardingCubit>().updateLocationContact(address: val),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Business Phone Number'),
              AppTextField(
                hint: '+1 (555) 000-0000',
                keyboardType: TextInputType.phone,
                onChanged: (val) => context.read<OnboardingCubit>().updateLocationContact(phone: val),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Support Email'),
              AppTextField(
                hint: 'contact@yourbusiness.com',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => context.read<OnboardingCubit>().updateLocationContact(email: val),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
