import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/models/data_models/user.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile_screen/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/change_password_screen/view/change_password_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_confirmation_sheet/cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_confirmation_sheet/view/delete_account_confirmation_sheet.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/edit_profile_screen/view/edit_profile_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/discovery_settings.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/review_notification_toggle.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_version_widget.dart';
import 'package:nearvendorapp/views/widgets/guest_auth_banner.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: Scaffold(
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: LoadingAnimation());
            }

            if (state is ProfileFailure) {
              return Center(
                child: Text(state.error, style: theme.textTheme.bodyMedium),
              );
            }

            if (state is ProfileSuccess) {
              return ValueListenableBuilder<User?>(
                valueListenable: AppData().userNotifier,
                builder: (context, user, child) {
                  final bool isGuest = user == null;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: theme.scaffoldBackgroundColor
                            .withValues(alpha: 0.9),
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        pinned: true,
                        centerTitle: true,
                        title: Text(
                          'Profile',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
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
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              const GuestAuthBanner(),
                              SizedBox(
                                height: AppSpacing.largeVerticalSpacing(
                                  context,
                                ),
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
                                onEditProfile: () {
                                  AppNavigator.push(
                                    context,
                                    const EditProfileScreen(),
                                  );
                                },
                              ),
                              SizedBox(
                                height: AppSpacing.largeVerticalSpacing(
                                  context,
                                ),
                              ),

                              _buildSectionTitle(context, 'PREFERENCES'),
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
                                height: AppSpacing.mediumVerticalSpacing(
                                  context,
                                ),
                              ),
                              ReviewNotificationToggle(
                                enabled: state.reviewNotifications,
                                onToggle: (value) => context
                                    .read<ProfileCubit>()
                                    .toggleReviewNotifications(value),
                              ),
                              SizedBox(
                                height: AppSpacing.mediumVerticalSpacing(
                                  context,
                                ),
                              ),

                              _buildSectionTitle(context, 'ACCOUNT SETTINGS'),
                              _buildSettingsGroup(
                                context,
                                children: [
                                  ProfileMenuItem(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Edit Profile',
                                    subtitle:
                                        'Update your name and profile picture',
                                    onTap: () {
                                      AppNavigator.push(
                                        context,
                                        const EditProfileScreen(),
                                      );
                                    },
                                  ),
                                  const Divider(
                                    height: 1,
                                    indent: 64,
                                    endIndent: 20,
                                  ),
                                  ProfileMenuItem(
                                    icon: Icons.lock_outline_rounded,
                                    title: 'Change Password',
                                    subtitle:
                                        'Update your security credentials',
                                    onTap: () {
                                      AppNavigator.push(
                                        context,
                                        const ChangePasswordScreen(),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: AppSpacing.mediumVerticalSpacing(
                                  context,
                                ),
                              ),

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
                                  const Divider(
                                    height: 1,
                                    indent: 64,
                                    endIndent: 20,
                                  ),
                                  ProfileMenuItem(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: 'Read our terms and conditions',
                                    onTap: () {},
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: AppSpacing.largeVerticalSpacing(
                                  context,
                                ),
                              ),
                              _buildLogoutButton(context),
                              const SizedBox(height: 12),
                              _buildDeleteAccountButton(context),
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
        bottomNavigationBar: const AppVersionWidget(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showLogoutConfirmationDialog(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.red.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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

  Widget _buildDeleteAccountButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDeleteAccountDialog(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withValues(alpha: isDark ? 0.25 : 0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete Account',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.red.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    AppBottomSheet.showBottomSheet(
      context: context,
      isScrollControlled: true,
      child: BlocProvider(
        create: (_) => DeleteAccountCubit(),
        child: const DeleteAccountConfirmationSheet(),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    AppBottomSheet.showConfirmationBottomSheet(
      context: context,
      title: 'Log Out',
      message:
          'Are you sure you want to log out? For your security, all your local data, including cached location details, search history, and offline settings, will be permanently deleted from this device.',
      confirmButtonText: 'Log Out',
      confirmButtonColor: Colors.red.shade600,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.red.shade600,
      onConfirm: logoutUser,
    );
  }
}
