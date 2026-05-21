import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/enums/auth_status.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile/view/profile_screen.dart';
import 'package:nearvendorapp/views/widgets/circular_cached_network_image.dart';
import 'package:nearvendorapp/views/widgets/location_display_row.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.mediumHorizontalSpacing(context),
        vertical: 12.0,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: LocationDisplayRow()),
          SizedBox(width: 16),
          _ProfileHeader(),
        ],
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
                    color: theme.primaryColor,
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
