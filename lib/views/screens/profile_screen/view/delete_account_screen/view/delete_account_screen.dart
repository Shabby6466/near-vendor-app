import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/onboarding/view/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_screen/cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_screen/cubit/delete_account_state.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => DeleteAccountCubit(),
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) async {
          if (state.status == DeleteAccountStatus.success) {
            await AppData().clear();
            if (context.mounted) {
              AppNavigator.pop(context);
              AppNavigator.pushAndRemoveUntil(context, const WelcomeScreen());
            }
          } else if (state.status == DeleteAccountStatus.failure &&
              state.errorMessage != null) {
            AppAlerts.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          final cubit = context.read<DeleteAccountCubit>();
          final isLoading = state.status == DeleteAccountStatus.submitting;

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
                        'Delete Account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please review the details below before deleting your account.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),

                      // Warning Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Important Warning',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Deleting your account is permanent and cannot be undone. All your profile information, settings, listings, wallet data, and transaction history will be permanently deleted and cannot be recovered.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.red.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),

                      _buildLabel(context, 'Confirm Password'),
                      AppTextField(
                        controller: cubit.passwordController,
                        hint: 'Enter your password to verify',
                        isPassword: true,
                        showBorder: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password to confirm';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),

                      // Checkbox confirmation
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: state.isConfirmed,
                              onChanged: isLoading
                                  ? null
                                  : (val) => cubit.toggleConfirmation(val),
                              activeColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => cubit.toggleConfirmation(
                                      !state.isConfirmed,
                                    ),
                              child: Text(
                                'I understand that my account will be permanently deleted along with all its data, and that this action is irreversible.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      AppElevatedButton(
                        onPressed: () => cubit.deleteAccount(),
                        text: 'Delete Account',
                        isEnabled: state.isConfirmed,
                        color: Colors.red.shade600,
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
