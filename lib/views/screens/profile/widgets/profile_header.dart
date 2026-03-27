import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String? profileImagePath;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userLocation,
    this.profileImagePath,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        Center(
          child: SvgPicture.asset(
            'assets/icons/near_vendor_blue_text.svg',
            height: 40,
            colorFilter: ColorFilter.mode(
              theme.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context) * 2),
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2), 
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: profileImagePath != null
                    ? Image.file(
                        File(profileImagePath!),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://i.pravatar.cc/150?img=11',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        Text(
          userName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded, 
              color: theme.primaryColor, 
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              userLocation,
              style: TextStyle(
                fontSize: 14,
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
