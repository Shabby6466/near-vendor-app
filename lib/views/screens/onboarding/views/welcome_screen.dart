import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/vendor_dashboard_screen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/widget/onboaring_btns.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/screens/vendor_onboarding_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      bgColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: isDark ? 0.3 : 1.0,
                child: Assets.icons.hearts.svg(),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Assets.icons.everythingNearYouText.svg(
                colorFilter: ColorFilter.mode(
                  theme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Nearvendor brings everything\nnear you!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: (0.7),
                  ),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                width: AppSpacing.screenWidth(context) * 0.7,
                Assets.images.nearVendorSideCut.path,
                color: isDark
                    ? theme.primaryColor.withValues(alpha: (0.3))
                    : null,
                colorBlendMode: isDark ? BlendMode.srcIn : null,
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
                color: theme.primaryColor,
                textColor: Colors.white,
                onTap: () {
                  final isVendor = context.read<SessionCubit>().state.isVendor;
                  if (isVendor) {
                    AppNavigator.push(context, const VendorDashboardScreen());
                  } else {
                    AppNavigator.push(context, const VendorOnboardingScreen());
                  }
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              SizedBox(width: AppSpacing.mediumHorizontalSpacing(context)),
              OnboardingBtns(
                btnText: 'Let\'s explore',
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                textColor: theme.textTheme.bodyLarge?.color ?? Colors.black,
                onTap: () {
                  context.read<SessionCubit>().setOnboarded();
                  AppNavigator.pushReplacement(context, const MainScreen());
                },
                borderRadius: const BorderRadius.only(
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
