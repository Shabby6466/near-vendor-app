import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/view/welcome_screen.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/delete_account_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/view/change_password_screen.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/discovery_settings.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:nearvendorapp/views/widgets/guest_auth_banner.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

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
              return const Center(child: LoadingAnimation());
            }

            if (state is ProfileFailure) {
              return Center(
                child: Text(state.error, style: theme.textTheme.bodyMedium),
              );
            }

            if (state is ProfileSuccess) {
              return BlocBuilder<SessionCubit, SessionState>(
                builder: (context, sessionState) {
                  final bool isGuest = sessionState.status == AuthStatus.guest;

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
                                onEditProfile: () => context
                                    .read<ProfileCubit>()
                                    .pickImageFromGallery(),
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

                              _buildSectionTitle(context, 'ACCOUNT SETTINGS'),
                              _buildSettingsGroup(
                                context,
                                children: [
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
          onTap: () async {
            await context.read<SessionCubit>().logout();
            if (context.mounted) {
              AppNavigator.pushAndRemoveUntil(context, const MainScreen());
            }
          },
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
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider(
        create: (_) => DeleteAccountCubit(),
        child: _DeleteAccountDialog(isDark: isDark, sessionCubit: sessionCubit),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog widget — driven entirely by DeleteAccountCubit
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatefulWidget {
  final bool isDark;
  final SessionCubit sessionCubit;

  const _DeleteAccountDialog({
    required this.isDark,
    required this.sessionCubit,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) async {
        if (state is DeleteAccountSuccess) {
          // Pop the dialog, then clear session and navigate to WelcomeScreen,
          // removing all existing routes from the stack.
          Navigator.of(context).pop();
          await widget.sessionCubit.logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is DeleteAccountLoading;
        final errorMessage = state is DeleteAccountFailure ? state.error : null;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: isDark ? const Color(0xFF1E242B) : Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(18),
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
              const SizedBox(height: 20),
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will permanently delete your account and all associated data. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                enabled: !isLoading,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your password to confirm',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              // Error message
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade400,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                                .read<DeleteAccountCubit>()
                                .deleteAccount(_passwordController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.shade600.withValues(
                          alpha: 0.6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Delete',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
