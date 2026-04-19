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
        final theme = Theme.of(context);
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
              _buildLabel(context, 'Business Category'),
              state.isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.primaryColor,
                          ),
                          hint: Text(
                            'Select a category',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                          value: state.category.isEmpty ? null : state.category,
                          dropdownColor: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          items: state.availableCategories.map((category) {
                            return DropdownMenuItem(
                              value: category.name,
                              child: Text(
                                category.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => context.read<OnboardingCubit>().updateBusinessInfo(category: val),
                        ),
                      ),
                    ),
              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
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
