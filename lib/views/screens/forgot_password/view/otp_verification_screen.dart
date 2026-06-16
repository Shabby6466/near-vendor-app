import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:nearvendorapp/views/screens/forgot_password/view/reset_password_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_pin_code_field.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpVerified) {
          AppNavigator.push(
            context,
            BlocProvider.value(
              value: context.read<ForgotPasswordCubit>(),
              child: const ResetPasswordScreen(),
            ),
          );
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
                'Verify OTP',
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
                            Icons.mark_email_unread_outlined,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.largeVerticalSpacing(context),
                        ),
                        Center(
                          child: Text(
                            'Verify OTP',
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
                            'Enter the OTP code sent to\n${cubit.emailController.text}',
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
                          key: cubit.otpFormKey,
                          child: Center(
                            child: AppPinCodeField(
                              controller: cubit.otpController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'OTP is required';
                                }
                                if (value.length < 6) {
                                  return 'OTP must be 6 digits';
                                }
                                return null;
                              },
                              onCompleted: (pin) => cubit.verifyOtp(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.largeVerticalSpacing(context),
                        ),
                        AppElevatedButton(
                          onPressed: cubit.verifyOtp,
                          text: 'Verify OTP',
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
