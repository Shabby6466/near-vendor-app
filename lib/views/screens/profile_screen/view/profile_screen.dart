import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile_screen/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/change_password_screen/view/change_password_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_confirmation_sheet/cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/delete_account_confirmation_sheet/view/delete_account_confirmation_sheet.dart';
import 'package:nearvendorapp/views/screens/profile_screen/view/edit_profile_screen/view/edit_profile_screen.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile_screen/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/widgets/app_bottom_sheet.dart';
import 'package:nearvendorapp/views/widgets/app_version_widget.dart';
import 'package:nearvendorapp/views/widgets/guest_auth_banner.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0.9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: LoadingAnimation());
            }

            if (state is ProfileSuccess) {
              return _buildProfileContent(context);
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: const AppVersionWidget(),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding(context).left,
      ),
      child: Column(
        children: [
          if (cubit.isGuest) ...[
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            const Center(child: GuestAuthBanner()),
          ] else ...[
            Center(
              child: ProfileHeader(
                userName: cubit.userName ?? '',
                userLocation: cubit.userLocation,
                photoUrl: cubit.photoUrl,
                isUploadingImage: cubit.isUploadingImage,
                onEditProfile: () =>
                    AppNavigator.push(context, const EditProfileScreen()),
              ),
            ),
          ],

          SizedBox(height: AppSpacing.largeVerticalSpacing(context)),

          _SettingsSection(
            title: 'PREFERENCES',
            children: [
              _StatefulSwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'New Offer Alerts',
                subtitle: 'Notify me about new offers nearby',
                initialValue: cubit.newOfferAlerts,
                onToggle: cubit.toggleOfferAlerts,
              ),
              const _SectionDivider(),
              _StatefulSliderTile(
                icon: Icons.radar_rounded,
                title: 'Discovery Radius',
                initialValue: cubit.discoveryRadius,
                min: 1,
                max: 50,
                onChanged: cubit.updateRadius,
              ),
              if (!cubit.isGuest) ...[
                const _SectionDivider(),
                _StatefulSwitchTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Review Notifications',
                  subtitle: 'Get notified when someone replies',
                  initialValue: cubit.reviewNotifications,
                  onToggle: cubit.toggleReviewNotifications,
                ),
              ],
            ],
          ),

          if (!cubit.isGuest) ...[
            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _SettingsSection(
              title: 'ACCOUNT SETTINGS',
              children: [
                ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your name and profile picture',
                  onTap: () =>
                      AppNavigator.push(context, const EditProfileScreen()),
                ),
                const _SectionDivider(),
                ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your security credentials',
                  onTap: () =>
                      AppNavigator.push(context, const ChangePasswordScreen()),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
            _SettingsSection(
              title: 'SUPPORT',
              children: [
                ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact information',
                  onTap: () {},
                ),
                const _SectionDivider(),
                ProfileMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our terms and conditions',
                  onTap: () {},
                ),
              ],
            ),

            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            _buildActionButtons(context),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final redColor = Colors.red.withValues(alpha: 0.8);
    final borderColor = Colors.red.withValues(alpha: isDark ? 0.25 : 0.15);
    final borderRadius = BorderRadius.circular(20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showLogoutConfirmationDialog(context),
              icon: Icon(Icons.logout_rounded, color: redColor),
              label: Text(
                'Log Out',
                style: TextStyle(
                  color: redColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                backgroundColor: redColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(context),
              icon: Icon(
                Icons.delete_forever_rounded,
                color: redColor,
                size: 20,
              ),
              label: Text(
                'Delete Account',
                style: TextStyle(
                  color: redColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
              ),
            ),
          ),
        ],
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.05),
              ),
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
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 76, endIndent: 20, thickness: 1);
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? bottom;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,

                    color: theme.iconTheme.color?.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (trailing != null) ...[const SizedBox(width: 16), trailing!],
            ],
          ),
        ),

        if (bottom != null)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 16, bottom: 12),
            child: bottom,
          ),
      ],
    );
  }
}

class _StatefulSwitchTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool initialValue;
  final ValueChanged<bool> onToggle;

  const _StatefulSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.onToggle,
  });

  @override
  State<_StatefulSwitchTile> createState() => _StatefulSwitchTileState();
}

class _StatefulSwitchTileState extends State<_StatefulSwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _StatefulSwitchTile old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return _PreferenceTile(
      icon: widget.icon,
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: Switch(
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onToggle(v);
        },
      ),
    );
  }
}

class _StatefulSliderTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final double initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _StatefulSliderTile({
    required this.icon,
    required this.title,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_StatefulSliderTile> createState() => _StatefulSliderTileState();
}

class _StatefulSliderTileState extends State<_StatefulSliderTile> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant _StatefulSliderTile old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreferenceTile(
      icon: widget.icon,
      title: widget.title,
      subtitle: '${_value.round()} km from your location',
      trailing: Text(
        '${_value.round()} km',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
      bottom: Slider(
        value: _value,
        min: widget.min,
        max: widget.max,
        divisions: (widget.max - widget.min).toInt(),
        onChanged: (v) => setState(() => _value = v),
        onChangeEnd: widget.onChanged,
      ),
    );
  }
}
