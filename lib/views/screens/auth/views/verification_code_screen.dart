import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/models/api_inputs/auth_api_inputs.dart';
import 'package:nearvendorapp/services/auth_services.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart' show MainScreen;
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/cubit/general_pin_cubit.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:pinput/pinput.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralPinCubit(),
      child: BlocConsumer<GeneralPinCubit, GeneralPinState>(
        listener: (context, state) {
          if (state is GeneralPinSuccess) {
            // Success logic handled in onPinSubmitted usually, but we'll adapt
          } else if (state is GeneralPinFailure) {
            // Errors handled via cubit.onFailure
          }
        },
        builder: (context, state) {
          final cubit = context.read<GeneralPinCubit>();
          final currentCode = state is GeneralPinCodeChanged
              ? state.code
              : cubit.codeController.text;
          
          final isButtonEnabled = state is! GeneralPinLoading && currentCode.length == 6;

          return Theme(
            data: AppThemeData.normalDarkTheme, // Standard Blue Version
            child: LoadingScreenView(
              isLoading: state is GeneralPinLoading,
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
                      child: LayoutBuilder(builder: (context, constraints) {
                        final theme = Theme.of(context);
                        final onSurface = theme.colorScheme.onSurface;

                        // Pin Input Styling for Blue Theme
                        final defaultPinTheme = PinTheme(
                          width: 56,
                          height: 64,
                          textStyle: theme.textTheme.headlineSmall?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: onSurface.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                        );

                        final focusedPinTheme = defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration?.copyWith(
                            border: Border.all(
                              color: theme.primaryColor, // Standard Blue
                              width: 2,
                            ),
                          ),
                        );

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: AppSpacing.bottomNavigationPadding(context)
                              .copyWith(left: 24, right: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight -
                                  AppSpacing.bottomNavigationPadding(context)
                                      .bottom,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Segment: Branding & Identity
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 48),

                                    // Logo
                                    Assets.icons.nearVendorText
                                        .svg(
                                          height: 32,
                                          colorFilter: ColorFilter.mode(
                                            onSurface,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .slideX(begin: -0.2, end: 0),

                                    const SizedBox(height: 24),

                                    // Heading
                                    Text(
                                      AppStrings.enterCodeTitle,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                        height: 1.1,
                                        letterSpacing: -1,
                                      ),
                                    ).animate().fadeIn(delay: 200.ms, duration: 200.ms).slideY(begin: 0.1, end: 0),

                                    const SizedBox(height: 8),

                                    RichText(
                                      text: TextSpan(
                                        text: AppStrings.enterCodeSubtitle,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: onSurface.withValues(alpha: 0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' $email',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: 200.ms),
                                  ],
                                ),

                                // Bottom Segment: Interaction
                                Column(
                                  children: [
                                    const SizedBox(height: 48),

                                    // PIN Input
                                    Center(
                                      child: Pinput(
                                        controller: cubit.codeController,
                                        length: 6,
                                        defaultPinTheme: defaultPinTheme,
                                        focusedPinTheme: focusedPinTheme,
                                        submittedPinTheme: focusedPinTheme,
                                        onChanged: cubit.onCodeChanged,
                                        cursor: Container(
                                          height: 24,
                                          width: 2,
                                          color: theme.primaryColor,
                                        ),
                                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                                    ),

                                    const SizedBox(height: 48),

                                    // CTA Button
                                    AppElevatedButton(
                                      onPressed: isButtonEnabled
                                          ? () async {
                                              final code = cubit.codeController.text;
                                              cubit.setLoading(true);
                                              final response = await AuthServices().verifyOtp(
                                                VerifyOtpInput(email: email, otp: code),
                                              );
                                              cubit.setLoading(false);
                                              
                                              if (response.status == 200 || response.status == 201) {
                                                if (response.user != null && response.token != null) {
                                                  await CurrentUserStorage.storeUserData(response.user);
                                                  await CurrentUserStorage.storeUserAuthToken(response.token!, null);
                                                  if (context.mounted) {
                                                    context.read<SessionCubit>().setAuthenticated(response.user);
                                                    context.read<SessionCubit>().updateLocation(); // Auto update location
                                                    AppNavigator.pushAndRemoveUntil(context, const MainScreen());
                                                  }
                                                }
                                              } else if (response.status == 403) {
                                                if (context.mounted) {
                                                  AppAlerts.showActionError(
                                                    context,
                                                    title: 'Invalid Code',
                                                    message: response.message ?? 'The verification code you entered is incorrect.',
                                                    actionText: 'Try Again',
                                                    onAction: () {
                                                      cubit.codeController.clear();
                                                      cubit.onCodeChanged('');
                                                    },
                                                    secondaryActionText: 'Go Back & Re-enter Details',
                                                    onSecondaryAction: () {
                                                      AppNavigator.pop(context);
                                                    },
                                                  );
                                                }
                                              } else {
                                                if (context.mounted) {
                                                  AppAlerts.showErrorSnackBar(
                                                    context,
                                                    response.message ?? 'Verification failed',
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                      isEnabled: isButtonEnabled,
                                      text: AppStrings.verifyButton.toUpperCase(),
                                    ).animate().fadeIn(delay: 600.ms).scale(
                                      begin: const Offset(0.95, 0.95), 
                                      end: const Offset(1, 1),
                                      curve: Curves.easeOutBack,
                                    ),

                                    const SizedBox(height: 24),

                                    // Dynamic spacer for keyboard
                                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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
