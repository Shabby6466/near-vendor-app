import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:nearvendorapp/views/screens/forgot_password/view/otp_verification_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpSent) {
            AppNavigator.push(
              context,
              BlocProvider.value(
                value: context.read<ForgotPasswordCubit>(),
                child: const OtpVerificationScreen(),
              ),
            );
          } else if (state is ForgotPasswordError) {
            AppAlerts.showError(context, state.message, isDarkBackground: true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          return LoadingScreenView(
            isLoading: state is ForgotPasswordLoading,
            child: AuthScaffold(
              appBar: AppBar(
                title: const Text(
                  'FORGOT PASSWORD',
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
                    final theme = Theme.of(context);
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: AppSpacing.bottomNavigationPadding(
                        context,
                      ).copyWith(left: 24, right: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight -
                              AppSpacing.bottomNavigationPadding(
                                context,
                              ).bottom,
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
                                    Icons.vpn_key_outlined,
                                    size: 80,
                                    color: ColorName.primary,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: Text(
                                    'Forgot Password',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 26,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'Enter your email address below to reset your password.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
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
                                  key: cubit.emailFormKey,
                                  child: Center(
                                    child: AppTextField(
                                      hint: 'EMAIL ADDRESS',
                                      controller: cubit.emailController,
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: TextFieldValidators
                                          .emailFieldValidation,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                AppElevatedButton(
                                  onPressed: cubit.sendOtp,
                                  text: 'SEND OTP',
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
      ),
    );
  }
}
