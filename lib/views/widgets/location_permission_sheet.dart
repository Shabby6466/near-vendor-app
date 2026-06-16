import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: AppAnimateList.stagger([
        Center(
          child: Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Icon(Icons.location_on_rounded, size: 64, color: theme.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Location Access Required',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'To view nearby shops and products, please allow location access or pick a location manually.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        AppElevatedButton(
          onPressed: () async {
            AppNavigator.pop(context);
            await LocationPickerLauncher.open(context);
          },
          text: 'SET LOCATION',
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => AppNavigator.pop(context),
          child: Text(
            'Skip for Now',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ]),
    );
  }
}
