import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/discovery_settings.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/screens/vendor/onboarding/screens/vendor_onboarding_screen.dart';
import 'package:nearvendorapp/views/screens/profile/view/change_password_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/guest_auth_banner.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => ProfileCubit(context.read<SessionCubit>()),
      child: AppScaffold(
        bgColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              );
            }

            if (state is ProfileFailure) {
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              );
            }

            if (state is ProfileSuccess) {
              return BlocBuilder<SessionCubit, SessionState>(
                builder: (context, sessionState) {
                  final bool isGuest = sessionState.status == AuthStatus.guest;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        pinned: true,
                        centerTitle: true,
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding(context).left,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (isGuest) ...[
                              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                              const GuestAuthBanner(),
                              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                              DiscoverySettings(
                                radius: state.discoveryRadius,
                                newOfferAlerts: state.newOfferAlerts,
                                onRadiusChanged: (value) =>
                                    context.read<ProfileCubit>().updateRadius(value),
                                onAlertsToggled: (value) =>
                                    context.read<ProfileCubit>().toggleOfferAlerts(value),
                              ),
                            ] else ...[
                              ProfileHeader(
                                userName: state.userName,
                                userLocation: state.userLocation,
                                photoUrl: state.photoUrl,
                                isUploadingImage: state.isUploadingImage,
                                onEditProfile: () =>
                                    context.read<ProfileCubit>().pickImageFromGallery(),
                              ),
                              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),

                              // Preferences Section
                              _buildSectionTitle(context, 'PREFERENCES'),
                              DiscoverySettings(
                                radius: state.discoveryRadius,
                                newOfferAlerts: state.newOfferAlerts,
                                onRadiusChanged: (value) =>
                                    context.read<ProfileCubit>().updateRadius(value),
                                onAlertsToggled: (value) =>
                                    context.read<ProfileCubit>().toggleOfferAlerts(value),
                              ),
                              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),

                              // Account Section
                              _buildSectionTitle(context, 'ACCOUNT SETTINGS'),
                              _buildSettingsGroup(
                                context,
                                children: [
                                  if (sessionState.isVendor)
                                    ProfileMenuItem(
                                      icon: Icons.storefront_outlined,
                                      title: 'Merchant Console',
                                      subtitle: 'Vendor Account Status',
                                      trailing: sessionState.vendorStatus == null
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: sessionState.vendorStatus == 'APPROVED'
                                                    ? Colors.green.withValues(alpha: 0.1)
                                                    : theme.dividerColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                sessionState.vendorStatus ?? 'PENDING',
                                                style: TextStyle(
                                                  color: sessionState.vendorStatus == 'APPROVED'
                                                      ? Colors.green
                                                      : theme.textTheme.bodyMedium?.color
                                                          ?.withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                    )
                                  else
                                    ProfileMenuItem(
                                      icon: Icons.storefront_outlined,
                                      title: 'Merchant Console',
                                      subtitle: 'Become a vendor and start selling',
                                      onTap: () {
                                        AppNavigator.push(context, const VendorOnboardingScreen());
                                      },
                                    ),
                                  const Divider(height: 1, indent: 64, endIndent: 20),
                                  ProfileMenuItem(
                                    icon: Icons.lock_outline_rounded,
                                    title: 'Change Password',
                                    subtitle: 'Update your security credentials',
                                    onTap: () {
                                      AppNavigator.push(context, const ChangePasswordScreen());
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),

                              // Support Section
                              _buildSectionTitle(context, 'SUPPORT'),
                              _buildSettingsGroup(
                                context,
                                children: [
                                  ProfileMenuItem(
                                    icon: Icons.help_outline_rounded,
                                    title: 'Help & Support',
                                    subtitle: 'FAQs and contact information',
                                    onTap: () {},
                                  ),
                                  const Divider(height: 1, indent: 64, endIndent: 20),
                                  ProfileMenuItem(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: 'Read our terms and conditions',
                                    onTap: () {},
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                              _buildLogoutButton(context),
                            ],
                            const SizedBox(height: 100),
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await context.read<SessionCubit>().logout();
            if (context.mounted) {
              AppNavigator.pushAndRemoveUntil(context, const MainScreen());
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

