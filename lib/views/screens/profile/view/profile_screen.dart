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
                          if (isGuest) ...[
                            // Center the guest banner in the remaining space if possible
                            // or just give it some top padding if it's the only thing.
                            // The user said "not in center", so I'll wrap it in a Center and Add some spacing.
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            const GuestAuthBanner(),
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
                          ] else ...[
                            ProfileHeader(
                              userName: state.userName,
                              userLocation: state.userLocation,
                              photoUrl: state.photoUrl,
                              isUploadingImage: state.isUploadingImage,
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
                            if (sessionState.isVendor)
                              ProfileMenuItem(
                                icon: Icons.storefront_outlined,
                                title: 'Merchant Console',
                                subtitle: 'Vendor Account Status',
                                trailing: sessionState.vendorStatus == null
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              sessionState.vendorStatus ==
                                                      'APPROVED'
                                                  ? Colors.green.withValues(
                                                      alpha: 0.1,
                                                    )
                                                  : theme.dividerColor
                                                      .withValues(
                                                      alpha: 0.1,
                                                    ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          sessionState.vendorStatus ??
                                              'PENDING',
                                          style: TextStyle(
                                            color: sessionState.vendorStatus ==
                                                    'APPROVED'
                                                ? Colors.green
                                                : theme.textTheme.bodyMedium
                                                    ?.color
                                                    ?.withValues(alpha: 0.6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
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
                                  AppNavigator.push(
                                    context,
                                    const VendorOnboardingScreen(),
                                  );
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
                            _buildLogoutButton(context),
                          ],
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
          border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: theme.iconTheme.color?.withValues(alpha: 0.7),
              size: 20,
            ),
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

