import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/auth/views/location_picker_screen.dart';
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
          final locationText =
              state.cityName ??
              (state.latitude != null && state.longitude != null
                  ? '${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}'
                  : 'Select Location');

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<SessionCubit>().startManualLocationPick();
                    AppNavigator.push(context, const LocationPickerScreen());
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Current Location',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
        final bool isGuest = state.status == AuthStatus.guest;
        final String name = isGuest ? 'Sign In' : (state.userName ?? 'User');

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
                  if (!isGuest)
                    Text(
                      'Hello',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
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
