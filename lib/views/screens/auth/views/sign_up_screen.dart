import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/signup_cubit/signup_cubit.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';
import 'package:nearvendorapp/views/screens/auth/views/verification_code_screen.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
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
            final LatLng? result =
                await AppNavigator.push(context, const LocationPickerScreen())
                    as LatLng?;
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
            AppAlerts.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();
          return Theme(
            data: AppThemeData.normalDarkTheme,
            child: LoadingScreenView(
              isLoading: state is SignupLoading,
              child: AppScaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --- Layer 1: Background Image ---
                    Image.asset(Assets.images.itemsArt.path, fit: BoxFit.cover),

                    // --- Layer 2: Sophisticated Blur & Gradient ---
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.7),
                              Colors.black.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- Layer 3: Content ---
                    SafeArea(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Segment: Branding & Identity
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 48),

                                      // Logo
                                      Assets.icons.nearVendorText
                                          .svg(
                                            height: 32,
                                            colorFilter: ColorFilter.mode(
                                              theme.colorScheme.onSurface,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(duration: 200.ms)
                                          .slideX(begin: -0.2, end: 0),

                                      const SizedBox(height: 24),

                                      // Heading
                                      Text(
                                            'Create Account to get started',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 28,
                                                  height: 1.1,
                                                  letterSpacing: -1,
                                                ),
                                          )
                                          .animate()
                                          .fadeIn(
                                            delay: 200.ms,
                                            duration: 200.ms,
                                          )
                                          .slideY(begin: 0.1, end: 0),

                                      const SizedBox(height: 8),

                                      Text(
                                        'Join our community of millions of local shoppers and specialized vendors.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ).animate().fadeIn(
                                        delay: 200.ms,
                                        duration: 200.ms,
                                      ),
                                    ],
                                  ),

                                  // Bottom Segment: Interaction
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 48,
                                      ), // Gap between header and form
                                      // Form Section
                                      Form(
                                        key: cubit.formKey,
                                        child: Column(
                                          children: [
                                            AuthTextFieldWidget(
                                                  label: 'full name',
                                                  controller:
                                                      cubit.fullNameController,
                                                  prefixIcon:
                                                      Icons.person_outline,
                                                  validator: (v) =>
                                                      TextFieldValidators.emptyFieldValidator(
                                                        v,
                                                        'Please enter your full name',
                                                      ),
                                                )
                                                .animate()
                                                .fadeIn(delay: 200.ms)
                                                .slideY(begin: 0.1, end: 0),

                                            const SizedBox(height: 16),

                                            AuthTextFieldWidget(
                                                  label: 'email',
                                                  controller:
                                                      cubit.emailController,
                                                  prefixIcon:
                                                      Icons.email_outlined,
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  validator: TextFieldValidators
                                                      .emailFieldValidation,
                                                )
                                                .animate()
                                                .fadeIn(delay: 200.ms)
                                                .slideY(begin: 0.1, end: 0),

                                            const SizedBox(height: 16),

                                            AuthTextFieldWidget(
                                                  label: 'password',
                                                  isPassword: true,
                                                  controller:
                                                      cubit.passwordController,
                                                  prefixIcon:
                                                      Icons.lock_outline,
                                                  validator: TextFieldValidators
                                                      .passwordFieldValidator,
                                                )
                                                .animate()
                                                .fadeIn(delay: 200.ms)
                                                .slideY(begin: 0.1, end: 0),

                                            const SizedBox(height: 16),

                                            AuthTextFieldWidget(
                                                  label: 'confirm password',
                                                  isPassword: true,
                                                  controller: cubit
                                                      .confirmPasswordController,
                                                  prefixIcon:
                                                      Icons.lock_reset_outlined,
                                                  validator: (v) =>
                                                      TextFieldValidators.confirmPasswordValidator(
                                                        v,
                                                        cubit
                                                            .passwordController
                                                            .text,
                                                      ),
                                                )
                                                .animate()
                                                .fadeIn(delay: 200.ms)
                                                .slideY(begin: 0.1, end: 0),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 40),

                                      // CTA Button
                                      AppElevatedButton(
                                            onPressed: () {
                                              cubit.handleSignup();
                                            },
                                            isEnabled: true,
                                            text: 'CONTINUE',
                                          )
                                          .animate()
                                          .fadeIn(delay: 200.ms)
                                          .scale(
                                            begin: const Offset(0.95, 0.95),
                                            end: const Offset(1, 1),
                                            curve: Curves.easeOutBack,
                                          ),

                                      const SizedBox(height: 24),

                                      // Footer Links
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.5),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              AppNavigator.pop(context);
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                            child: Text(
                                              'SIGN IN',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ).animate().fadeIn(delay: 200.ms),

                                      // Dynamic spacer for keyboard
                                      SizedBox(
                                        height:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom +
                                            24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
