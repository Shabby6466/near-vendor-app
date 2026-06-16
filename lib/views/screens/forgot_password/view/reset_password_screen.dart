import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          AppAlerts.showSuccess(
            context,
            'Password reset successfully!',
            isDarkBackground: true,
          );
          AppNavigator.popUntilFirst(context);
        } else if (state is ForgotPasswordError) {
          AppAlerts.showError(context, state.message, isDarkBackground: true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();
        final theme = Theme.of(context);

        return LoadingScreenView(
          isLoading: state is ForgotPasswordLoading,
          child: AuthScaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.bottomNavigationPadding(
                  context,
                ).copyWith(left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Segment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AppAnimateList.stagger([
                        SizedBox(
                          height: AppSpacing.largeVerticalSpacing(context),
                        ),
                        const Center(
                          child: Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.largeVerticalSpacing(context),
                        ),
                        Center(
                          child: Text(
                            'Reset Password',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.smallVerticalSpacing(context),
                        ),
                        Center(
                          child: Text(
                            'Enter your new password below.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ]),
                    ),

                    // Bottom Segment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: AppAnimateList.stagger([
                        SizedBox(
                          height:
                              AppSpacing.extraLargeVerticalSpacing(context) * 2,
                        ),
                        Form(
                          key: cubit.passwordFormKey,
                          child: Column(
                            children: AppAnimateList.stagger([
                              AppTextField(
                                hint: 'New Password',
                                isPassword: true,
                                controller: cubit.newPasswordController,
                                prefixIcon: const Icon(Icons.lock_outline),
                                validator:
                                    TextFieldValidators.passwordFieldValidator,
                              ),
                              SizedBox(
                                height: AppSpacing.mediumVerticalSpacing(
                                  context,
                                ),
                              ),
                              AppTextField(
                                hint: 'Confirm Password',
                                isPassword: true,
                                controller: cubit.confirmPasswordController,
                                prefixIcon: const Icon(Icons.lock_outline),
                                validator: (value) =>
                                    TextFieldValidators.confirmPasswordValidator(
                                      value,
                                      cubit.newPasswordController.text,
                                    ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.largeVerticalSpacing(context),
                        ),
                        AppElevatedButton(
                          onPressed: cubit.resetPassword,
                          text: 'Reset Password',
                          color: theme.colorScheme.secondary,
                        ),
                        // Dynamic spacer for keyboard
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
