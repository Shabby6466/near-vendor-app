import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
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
    return Column(
      children: [
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        Center(
          child: SvgPicture.asset(
            'assets/icons/near_vendor_blue_text.svg',
            height: 40,
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
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: ColorName.primary,
                    shape: BoxShape.circle,
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, color: ColorName.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              userLocation,
              style: TextStyle(
                fontSize: 14,
                color: ColorName.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
