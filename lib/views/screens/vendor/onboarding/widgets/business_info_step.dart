import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/cubit/onboarding_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class BusinessInfoStep extends StatelessWidget {
  const BusinessInfoStep({super.key});

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
                'Business Information',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your business to help customers find you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
              _buildLabel(context, 'Business Name'),
              AppTextField(
                hint: 'e.g. Nearvendor Solutions',
                onChanged: (val) => context.read<OnboardingCubit>().updateBusinessInfo(name: val),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Category'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a category'),
                    value: state.category.isEmpty ? null : state.category,
                    items: ['Food', 'Retail', 'Services', 'Electronics'].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (val) => context.read<OnboardingCubit>().updateBusinessInfo(category: val),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
              _buildLabel(context, 'Business Description'),
              AppTextField(
                hint: 'Briefly describe what your business offers...',
                isMultiline: true,
                onChanged: (val) => context.read<OnboardingCubit>().updateBusinessInfo(description: val),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '0/500 characters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
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
