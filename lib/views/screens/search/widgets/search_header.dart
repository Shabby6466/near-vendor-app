import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile/view/profile_screen.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
        vertical: 12.0,
      ),
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          final locationText = state.cityName ??
              (state.latitude != null && state.longitude != null
                  ? '${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}'
                  : 'Select Location');

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<SessionCubit>().updateLocation();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.5,
                            ),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: theme.primaryColor.withValues(alpha: .5),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const _ProfileHeader(),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final String name = state.userName ?? 'Guest';

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            AppNavigator.push(context, const ProfileScreen());
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: CircularCachedNetworkImage(
                  imageUrl: state.photoUrl,
                  size: 36,
                  placeholder: Assets.icons.profileIcon.svg(
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      theme.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
