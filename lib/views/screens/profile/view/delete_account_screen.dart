import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/delete_account_cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => DeleteAccountCubit(),
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) async {
          if (state is DeleteAccountSuccess) {
            AppAlerts.showSuccess(context, 'Account deleted successfully.');
            await context.read<SessionCubit>().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            }
          } else if (state is DeleteAccountFailure) {
            AppAlerts.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is DeleteAccountLoading;

          return AppScaffold(
            bgColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: theme.iconTheme.color,
                ),
                onPressed: isLoading ? null : () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding(context),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
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

                      // Warning Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: isDark ? 0.3 : 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Important Warning',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Deleting your account is permanent and cannot be undone. All your profile information, settings, listings, wallet data, and transaction history will be permanently deleted and cannot be recovered.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.red.shade200 : Colors.red.shade800,
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

                      // Password Field
                      _buildLabel(context, 'Confirm Password'),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppTextField(
                          controller: _passwordController,
                          hint: 'Enter your password to verify',
                          isPassword: true,
                          enabled: !isLoading,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: AppSpacing.largeVerticalSpacing(context),
                      ),

                      // Terms and Conditions Checkbox
                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isChecked = !_isChecked;
                                });
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _isChecked,
                                  onChanged: isLoading
                                      ? null
                                      : (val) {
                                          setState(() {
                                            _isChecked = val ?? false;
                                          });
                                        },
                                  activeColor: Colors.red.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'I understand that my account will be permanently deleted along with all its data, and that this action is irreversible.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                    color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Delete Button
                      BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
                        builder: (context, state) {
                          return AppElevatedButton(
                            isEnabled: _isChecked,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<DeleteAccountCubit>().deleteAccount(
                                      _passwordController.text.trim(),
                                    );
                              }
                            },
                            text: 'Delete Account',

                          );
                        },
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

