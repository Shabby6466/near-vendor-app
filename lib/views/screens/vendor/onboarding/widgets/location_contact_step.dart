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
                'Vendor Details',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Provide your business phone and CNIC details for verification.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Support Contact (Phone)'),
              AppTextField(
                hint: 'e.g. +92 3XX XXXXXXX',
                keyboardType: TextInputType.phone,
                onChanged: (val) => context.read<OnboardingCubit>().updateLegalContact(phone: val),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Tax ID'),
              AppTextField(
                hint: 'e.g. 1234567-8',
                onChanged: (val) => context.read<OnboardingCubit>().updateLegalContact(taxId: val),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'CNIC Number'),
              AppTextField(
                hint: 'e.g. 12345-1234567-1',
                keyboardType: TextInputType.number,
                onChanged: (val) => context.read<OnboardingCubit>().updateLegalContact(cnic: val),
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
