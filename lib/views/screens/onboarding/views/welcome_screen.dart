import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/widget/onboaring_btns.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // void _openSignInScreen(BuildContext context) {
  //   AppNavigator.push(context, const SignInScreen());
  // }
  //
  // void _openSignUpScreen(BuildContext context) {
  //   AppNavigator.push(context, const SignUpEmailScreen());
  // }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Assets.icons.hearts.svg(),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Assets.icons.everythingNearYouText.svg(),
            ),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Nearvendor brings everything\nnear you!',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                width: AppSpacing.screenWidth(context) * 0.7,
                Assets.images.nearVendorSideCut.path,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.bottomNavigationPadding(context),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OnboardingBtns(
                btnText: 'Be a Vendor',
                onTap: () {
                  AppNavigator.push(context, const LoginScreen());
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              SizedBox(width: AppSpacing.mediumHorizontalSpacing(context)),
              OnboardingBtns(
                btnText: 'Let\'s explore',
                onTap: () {
                  AppNavigator.push(context, const LoginScreen());
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
