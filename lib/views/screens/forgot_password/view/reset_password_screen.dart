import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/textfield_validations.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/theme/app_theme_data.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/auth/widgets/auth_text_field_widget.dart';
import 'package:nearvendorapp/views/screens/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/auth_scaffold.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemeData.normalDarkTheme,
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
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
          final onSurface = theme.colorScheme.onSurface;

          return LoadingScreenView(
            isLoading: state is ForgotPasswordLoading,
            child: AuthScaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'RESET PASSWORD',
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
                          minHeight: constraints.maxHeight -
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
                                    Icons.lock_reset,
                                    size: 80,
                                    color: ColorName.primary,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: Text(
                                    'Reset Password',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: onSurface,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'Enter your new password below.',
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
                                  key: cubit.passwordFormKey,
                                  child: Column(
                                    children: AppAnimateList.stagger([
                                      AuthTextFieldWidget(
                                        label: 'new password',
                                        isPassword: true,
                                        controller: cubit.newPasswordController,
                                        prefixIcon: Icons.lock_outline,
                                        validator: TextFieldValidators.passwordFieldValidator,
                                      ),
                                      const SizedBox(height: 16),
                                      AuthTextFieldWidget(
                                        label: 'confirm password',
                                        isPassword: true,
                                        controller: cubit.confirmPasswordController,
                                        prefixIcon: Icons.lock_outline,
                                        validator: (value) => TextFieldValidators.confirmPasswordValidator(
                                          value,
                                          cubit.newPasswordController.text,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                AppElevatedButton(
                                  onPressed: cubit.resetPassword,
                                  text: 'RESET PASSWORD',
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
