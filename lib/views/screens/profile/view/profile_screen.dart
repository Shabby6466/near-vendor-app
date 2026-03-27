import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/views/screens/auth/views/sign_up_screen.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/discovery_settings.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/screens/vendor/dashboard/screens/vendor_dashboard_screen.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/screens/vendor_onboarding_screen.dart';
import 'package:nearvendorapp/views/screens/profile/view/change_password_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: AppScaffold(
        bgColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator(color: theme.primaryColor));
            }

            if (state is ProfileFailure) {
              return Center(child: Text(state.error, style: const TextStyle(fontFamily: 'Poppins')));
            }

            if (state is ProfileSuccess) {
              return SingleChildScrollView(
                child: Padding(
                  padding: AppSpacing.screenPadding(context),
                  child: BlocBuilder<SessionCubit, SessionState>(
                    builder: (context, sessionState) {
                      final bool isGuest =
                          sessionState.status == AuthStatus.guest;

                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          if (isGuest)
                            const _GuestAuthBanner()
                          else
                            ProfileHeader(
                              userName: state.userName,
                              userLocation: state.userLocation,
                              profileImagePath: state.profileImagePath,
                              onEditProfile: () => context
                                  .read<ProfileCubit>()
                                  .pickImageFromGallery(),
                            ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          DiscoverySettings(
                            radius: state.discoveryRadius,
                            newOfferAlerts: state.newOfferAlerts,
                            onRadiusChanged: (value) => context
                                .read<ProfileCubit>()
                                .updateRadius(value),
                            onAlertsToggled: (value) => context
                                .read<ProfileCubit>()
                                .toggleOfferAlerts(value),
                          ),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          ProfileMenuItem(
                            icon: Icons.storefront_outlined,
                            title: 'Merchant Console',
                            subtitle: sessionState.isVendor
                                ? 'Manage your shop and offers'
                                : 'Become a vendor and start selling',
                            onTap: () {
                              if (sessionState.isVendor) {
                                AppNavigator.push(
                                  context,
                                  const VendorDashboardScreen(),
                                );
                              } else {
                                AppNavigator.push(
                                  context,
                                  const VendorOnboardingScreen(),
                                );
                              }
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            subtitle: 'Update your security credentials',
                            onTap: () {
                              AppNavigator.push(
                                context,
                                const ChangePasswordScreen(),
                              );
                            },
                          ),
                          SizedBox(
                            height: AppSpacing.mediumVerticalSpacing(context),
                          ),
                          ProfileMenuItem(
                            icon: Icons.settings_input_component_outlined,
                            title: 'Notification Preferences',
                            subtitle: 'Manage how you receive updates',
                            onTap: () {},
                          ),
                          ProfileMenuItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'FAQs and contact information',
                            onTap: () {},
                          ),
                          SizedBox(
                            height: AppSpacing.largeVerticalSpacing(context),
                          ),
                          if (!isGuest) _buildLogoutButton(context),
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await context.read<SessionCubit>().logout();
        if (context.mounted) {
          AppNavigator.pushAndRemoveUntil(context, const MainScreen());
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: theme.iconTheme.color?.withOpacity(0.7), size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestAuthBanner extends StatelessWidget {
  const _GuestAuthBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.8),
            theme.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unlock the Full Experience!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join our community to shop, sell, and connect with top vendors.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => AppNavigator.push(context, const LoginScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => AppNavigator.push(context, const SignUpScreen()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
