import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/login_screen.dart';
import 'package:nearvendorapp/views/screens/profile/cubit/profile_cubit.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/discovery_settings.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_header.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/profile_menu_item.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: AppScaffold(
        bgColor: ColorName.white,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileFailure) {
              return Center(child: Text(state.error));
            }

            if (state is ProfileSuccess) {
              return SingleChildScrollView(
                child: Padding(
                  padding: AppSpacing.screenPadding(context),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      ProfileHeader(
                        userName: state.userName,
                        userLocation: state.userLocation,
                        profileImagePath: state.profileImagePath,
                        onEditProfile: () => context.read<ProfileCubit>().pickImageFromGallery(),
                      ),
                      SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                      DiscoverySettings(
                        radius: state.discoveryRadius,
                        newOfferAlerts: state.newOfferAlerts,
                        onRadiusChanged: (value) => context.read<ProfileCubit>().updateRadius(value),
                        onAlertsToggled: (value) => context.read<ProfileCubit>().toggleOfferAlerts(value),
                      ),
                      SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                      ProfileMenuItem(
                        icon: Icons.settings_input_component_outlined,
                        title: 'Notification Preferences',
                        subtitle: 'Customize what you hear from us',
                        onTap: () {},
                      ),
                      SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
                      _buildLogoutButton(context),
                      SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
                    ],
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
    return GestureDetector(
      onTap: () {
        AppNavigator.pushReplacement(context, const LoginScreen());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade100, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
