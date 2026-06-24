import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/onboarding/view/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_confirmation_sheet/cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_text_field.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class DeleteAccountConfirmationSheet extends StatelessWidget {
  const DeleteAccountConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) async {
        if (state is DeleteAccountSuccess) {
          AppNavigator.pop(context);
          await AppData().clear();
          if (context.mounted) {
            AppNavigator.pushAndRemoveUntil(context, const WelcomeScreen());
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<DeleteAccountCubit>();
        final isLoading = state is DeleteAccountLoading;
        final errorMessage = state is DeleteAccountFailure ? state.error : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: AppAnimateList.stagger([
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
            ),
            Text(
              'Delete Account',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will permanently delete your account and all associated data. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: cubit.passwordController,
              hint: 'Enter your password to confirm',
              isPassword: true,
              enabled: !isLoading,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : () => cubit.deleteAccount(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.red.shade600.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: LoadingAnimation(size: 18, color: Colors.white),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : () => AppNavigator.pop(context),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }
}
