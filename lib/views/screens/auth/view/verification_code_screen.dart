import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/utils/ui/app_strings.dart';
import 'package:nearvendorapp/views/screens/auth/cubit/verification_cubit.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
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
            AppAlerts.showError(context, state.message, isDarkBackground: true);
          }
        },
        builder: (context, state) {
          final cubit = context.read<VerificationCubit>();
          final currentCode = state is VerificationCodeChanged
              ? state.code
              : cubit.codeController.text;
          final isButtonEnabled =
              state is! VerificationLoading && currentCode.length == 6;
          final theme = Theme.of(context);

          return LoadingScreenView(
            isLoading: state is VerificationLoading,
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
                      // Top: Branding
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height: AppSpacing.extraLargeVerticalSpacing(
                              context,
                            ),
                          ),
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
                          Text(
                            AppStrings.enterCodeTitle,
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
                          RichText(
                            text: TextSpan(
                              text: AppStrings.enterCodeSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
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
                          ),
                        ], interval: 80.ms),
                      ),

                      // Bottom: PIN input + CTA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: AppAnimateList.stagger([
                          SizedBox(
                            height:
                                AppSpacing.extraLargeVerticalSpacing(context) *
                                3,
                          ),
                          Center(
                            child: Pinput(
                              controller: cubit.codeController,
                              length: 6,
                              defaultPinTheme: PinTheme(
                                width: 56,
                                height: 64,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 56,
                                height: 64,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              submittedPinTheme: PinTheme(
                                width: 56,
                                height: 64,
                                textStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: cubit.onCodeChanged,
                              // Submit directly when all 6 digits are entered
                              onCompleted: (_) => cubit.verifyOtp(),
                              cursor: Container(
                                height: 24,
                                width: 2,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          AppElevatedButton(
                            onPressed: isButtonEnabled ? cubit.verifyOtp : null,
                            isEnabled: isButtonEnabled,
                            text: 'Verify',
                          ),
                          // Dynamic spacer for keyboard
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 24,
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
