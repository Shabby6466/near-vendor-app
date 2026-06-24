import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/change_password_screen/cubit/change_password_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            AppAlerts.showSuccess(context, state.message);
            AppNavigator.pop(context);
          } else if (state is ChangePasswordFailure) {
            AppAlerts.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChangePasswordCubit>();
          final theme = Theme.of(context);
          final isLoading = state is ChangePasswordLoading;

          return LoadingScreenView(
            isLoading: isLoading,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => AppNavigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: AppSpacing.screenPadding(context),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Change Password',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure your account by updating your password regularly.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),

                      _buildLabel(context, 'Old Password'),
                      AppTextField(
                        controller: cubit.oldPasswordController,
                        hint: 'Enter current password',
                        isPassword: true,
                        showBorder: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: AppSpacing.mediumVerticalSpacing(context),
                      ),

                      _buildLabel(context, 'New Password'),
                      AppTextField(
                        controller: cubit.newPasswordController,
                        hint: 'Enter new password',
                        isPassword: true,
                        showBorder: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: AppSpacing.mediumVerticalSpacing(context),
                      ),

                      _buildLabel(context, 'Confirm New Password'),
                      AppTextField(
                        controller: cubit.confirmPasswordController,
                        hint: 'Confirm new password',
                        isPassword: true,
                        showBorder: true,
                        validator: (value) {
                          if (value != cubit.newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      AppElevatedButton(
                        onPressed: cubit.handleChangePassword,
                        text: 'Update Password',
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

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
