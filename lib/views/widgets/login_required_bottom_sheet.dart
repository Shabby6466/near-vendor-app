import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';

class LoginRequiredBottomSheet extends StatelessWidget {
  const LoginRequiredBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        const Icon(
          Icons.lock_outline,
          size: 64,
          color: ColorName.primary,
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        Text(
          'Login Required',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        Text(
          'Please login or create an account to access this feature and connect with vendors.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              AppNavigator.pop(context);
              AppNavigator.pushReplacement(
                context,
                const LoginScreen(),
              );
            },
            child: const Text('Login / Sign Up'),
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: Text(
            'Maybe Later',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.grey,fontSize: 14),
          ),
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
      ],
    );
  }
}
