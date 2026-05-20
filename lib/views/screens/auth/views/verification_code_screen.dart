import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/services/app_location_service.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/utils/app_strings.dart';
import 'package:nearvendorapp/utils/app_theme_data.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/verification_cubit/verification_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:pinput/pinput.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(email: email),
      child: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is VerificationSuccess) {
            context.read<SessionCubit>().setAuthenticated(state.user);
            AppLocationService.instance.updateFromGps();
            AppNavigator.pushAndRemoveUntil(context, const MainScreen());
          } else if (state is VerificationInvalidCode) {
            AppAlerts.showConfirmDialog(
              context: context,
              title: 'Invalid Code',
              message: state.message,
              confirmLabel: 'Try Again',
              onConfirm: () {
                context.read<VerificationCubit>().codeController.clear();
                context.read<VerificationCubit>().onCodeChanged('');
              },
            );
          } else if (state is VerificationFailure) {
            AppAlerts.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<VerificationCubit>();
          final currentCode = state is VerificationCodeChanged
              ? state.code
              : cubit.codeController.text;
          final isButtonEnabled =
              state is! VerificationLoading && currentCode.length == 6;

          return Theme(
            data: AppThemeData.normalDarkTheme,
            child: LoadingScreenView(
              isLoading: state is VerificationLoading,
              child: AppScaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(Assets.images.itemsArt.path, fit: BoxFit.cover),
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
                    SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final theme = Theme.of(context);
                          final onSurface = theme.colorScheme.onSurface;

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
                              ),
                            ),
                          );

                          final focusedPinTheme = defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration?.copyWith(
                              border: Border.all(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          );

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
                                  // Top: Branding
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 48),
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
                                      Text(
                                            AppStrings.enterCodeTitle,
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: onSurface,
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
                                      RichText(
                                        text: TextSpan(
                                          text: AppStrings.enterCodeSubtitle,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: onSurface.withValues(
                                                  alpha: 0.6,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                          children: [
                                            TextSpan(
                                              text: ' $email',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme.primaryColor,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 200.ms),
                                    ],
                                  ),

                                  // Bottom: PIN input + CTA
                                  Column(
                                    children: [
                                      const SizedBox(height: 48),
                                      Center(
                                        child:
                                            Pinput(
                                                  controller:
                                                      cubit.codeController,
                                                  length: 6,
                                                  defaultPinTheme:
                                                      defaultPinTheme,
                                                  focusedPinTheme:
                                                      focusedPinTheme,
                                                  submittedPinTheme:
                                                      focusedPinTheme,
                                                  onChanged:
                                                      cubit.onCodeChanged,
                                                  // Submit directly when all 6 digits are entered
                                                  onCompleted: (_) =>
                                                      cubit.verifyOtp(),
                                                  cursor: Container(
                                                    height: 24,
                                                    width: 2,
                                                    color: theme.primaryColor,
                                                  ),
                                                )
                                                .animate()
                                                .fadeIn(delay: 400.ms)
                                                .slideY(begin: 0.2, end: 0),
                                      ),
                                      const SizedBox(height: 48),
                                      AppElevatedButton(
                                            onPressed: isButtonEnabled
                                                ? cubit.verifyOtp
                                                : null,
                                            isEnabled: isButtonEnabled,
                                            text: AppStrings.verifyButton
                                                .toUpperCase(),
                                          )
                                          .animate()
                                          .fadeIn(delay: 600.ms)
                                          .scale(
                                            begin: const Offset(0.95, 0.95),
                                            end: const Offset(1, 1),
                                            curve: Curves.easeOutBack,
                                          ),
                                      const SizedBox(height: 24),
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
