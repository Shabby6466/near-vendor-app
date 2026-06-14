import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/signup_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/auth/view/verification_code_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) async {
          if (state is SignupRequiresManualLocation) {
            final result = await LocationPickerLauncher.open(context);
            if (!context.mounted) return;
            if (result != null) {
              context.read<SignupCubit>().handleSignupWithLocation(
                result.latitude,
                result.longitude,
              );
            }
          }
          if (state is SignupSuccess) {
            if (!context.mounted) return;
            AppNavigator.push(
              context,
              VerificationCodeScreen(email: state.email),
            );
          } else if (state is SignupFailure) {
            if (!context.mounted) return;
            AppAlerts.showError(context, state.message, isDarkBackground: true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();
          final theme = Theme.of(context);

          return LoadingScreenView(
            isLoading: state is SignupLoading,
            child: AuthScaffold(
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
                      // Top Segment: Branding & Identity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height: AppSpacing.extraLargeVerticalSpacing(
                              context,
                            ),
                          ),

                          // Logo
                          Assets.icons.nearVendorText.svg(
                            height: 32,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),

                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),

                          // Heading
                          Text(
                            'Create Account to get started',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),

                          SizedBox(
                            height: AppSpacing.smallVerticalSpacing(context),
                          ),

                          Text(
                            'Join our community of millions of local shoppers and specialized vendors.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ),

                      // Bottom Segment: Interaction
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height:
                                AppSpacing.extraLargeVerticalSpacing(context) *
                                2,
                          ),
                          // Form Section
                          Form(
                            key: cubit.formKey,
                            child: Column(
                              children: AppAnimateList.stagger([
                                AppTextField(
                                  hint: 'Full Name',
                                  controller: cubit.fullNameController,
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                  ),
                                  validator: (v) =>
                                      TextFieldValidators.emptyFieldValidator(
                                        v,
                                        'Please enter your full name',
                                      ),
                                ),

                                SizedBox(
                                  height: AppSpacing.mediumVerticalSpacing(
                                    context,
                                  ),
                                ),

                                AppTextField(
                                  hint: 'Email',
                                  controller: cubit.emailController,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                  ),
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  validator: TextFieldValidators
                                      .emailFieldValidation,
                                ),

                                SizedBox(
                                  height: AppSpacing.mediumVerticalSpacing(
                                    context,
                                  ),
                                ),

                                AppTextField(
                                  hint: 'Password',
                                  isPassword: true,
                                  controller: cubit.passwordController,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                  ),
                                  validator: TextFieldValidators
                                      .passwordFieldValidator,
                                ),

                                SizedBox(
                                  height: AppSpacing.mediumVerticalSpacing(
                                    context,
                                  ),
                                ),

                                AppTextField(
                                  hint: 'Confirm Password',
                                  isPassword: true,
                                  controller:
                                      cubit.confirmPasswordController,
                                  prefixIcon: const Icon(
                                    Icons.lock_reset_outlined,
                                  ),
                                  validator: (v) =>
                                      TextFieldValidators.confirmPasswordValidator(
                                        v,
                                        cubit.passwordController.text,
                                      ),
                                ),
                              ]),
                            ),
                          ),

                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),

                          // CTA Button
                          AppElevatedButton(
                            onPressed: () {
                              cubit.handleSignup();
                            },
                            text: 'Continue',
                          ),

                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),

                          // Footer Links
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  AppNavigator.pushReplacement(
                                    context,
                                    const LoginScreen(),
                                  );
                                },
                                child: Text(
                                  'Sign in',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Dynamic spacer for keyboard
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom +
                                24,
                          ),
                        ], interval: 80.ms),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
