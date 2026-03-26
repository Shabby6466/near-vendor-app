import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/cubit/onboarding_cubit.dart';

class VerificationLaunchStep extends StatelessWidget {
  const VerificationLaunchStep({super.key});

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
                'Verification & Launch',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please upload your cnic to verify your account and accept our vendor terms to go live.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
              _buildLabel(context, 'CNIC Image'),
              const Text('CNIC Front or Back Image', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.read<OnboardingCubit>().pickCnicImage(),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2), style: BorderStyle.solid),
                  ),
                  child: state.cnicImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(state.cnicImagePath!), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue),
                            const SizedBox(height: 8),
                            const Text('Tap to upload or drag and drop', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                            Text('JPG or PNG (max. 5MB)', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: state.termsAccepted,
                    onChanged: (val) => context.read<OnboardingCubit>().toggleTerms(val),
                    activeColor: ColorName.primary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Nearvendor Terms of Service',
                              style: TextStyle(color: ColorName.primary, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '\nBy checking this box, you confirm that your business information is accurate and you agree to our marketplace policies.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Our team typically reviews documents within 24-48 business hours.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
