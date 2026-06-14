import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:nearvendorapp/views/screens/forgot_password/view/reset_password_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:pinput/pinput.dart';

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
        final onSurface = theme.colorScheme.onSurface;

        final defaultPinTheme = PinTheme(
          width: 50,
          height: 56,
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: onSurface.withValues(alpha: 0.08)),
          ),
        );

        final focusedPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: ColorName.primary, width: 2),
          ),
        );

        final submittedPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: ColorName.primary.withValues(alpha: 0.3)),
          ),
        );

        final errorPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: Colors.red, width: 2),
          ),
        );

        return LoadingScreenView(
          isLoading: state is ForgotPasswordLoading,
          child: AuthScaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text(
                'VERIFY OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: AppSpacing.bottomNavigationPadding(
                      context,
                    ).copyWith(left: 24, right: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            AppSpacing.bottomNavigationPadding(context).bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Segment
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: AppAnimateList.stagger([
                              const SizedBox(height: 32),
                              const Center(
                                child: Icon(
                                  Icons.mark_email_unread_outlined,
                                  size: 80,
                                  color: ColorName.primary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: Text(
                                  'Verify OTP',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 26,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Enter the OTP code sent to\n${cubit.emailController.text}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ]),
                          ),

                          // Bottom Segment
                          Column(
                            children: AppAnimateList.stagger([
                              const SizedBox(height: 48),
                              Form(
                                key: cubit.otpFormKey,
                                child: Center(
                                  child: Pinput(
                                    length: 6,
                                    controller: cubit.otpController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    submittedPinTheme: submittedPinTheme,
                                    errorPinTheme: errorPinTheme,
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
                              const SizedBox(height: 40),
                              AppElevatedButton(
                                onPressed: cubit.verifyOtp,
                                text: 'VERIFY OTP',
                              ),
                              // Dynamic spacer for keyboard
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    24,
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
