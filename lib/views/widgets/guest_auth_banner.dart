import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/auth/view/login_screen.dart';
import 'package:nearvendorapp/views/screens/auth/view/sign_up_screen.dart';

class GuestAuthBanner extends StatelessWidget {
  const GuestAuthBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: theme.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock the Full Experience!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our community to shop, and connect with top vendors.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      AppNavigator.push(context, const LoginScreen()),
                  child: const Text('Login'),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      AppNavigator.push(context, const SignUpScreen()),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
