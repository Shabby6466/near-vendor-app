import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String? photoUrl;
  final VoidCallback onEditProfile;
  final bool isUploadingImage;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userLocation,
    this.photoUrl,
    required this.onEditProfile,
    this.isUploadingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isUploadingImage)
                const SizedBox(
                  width: 140,
                  height: 140,
                  child: LoadingAnimation(size: 20, color: Colors.white),
                ),
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircularCachedNetworkImage(
                        imageUrl: photoUrl,
                        size: 130,
                      ),
                    ),
                    if (!isUploadingImage)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: onEditProfile,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        Text(
          userName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.iconTheme.color?.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: theme.iconTheme.color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                userLocation,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  color: theme.iconTheme.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
