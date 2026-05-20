import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/models/data_models/app_location.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/location_picker_launcher.dart';

/// Shows the current saved location label and opens the picker on tap.
class LocationDisplayRow extends StatelessWidget {
  final String label;
  final bool compact;

  const LocationDisplayRow({
    super.key,
    this.label = 'Current Location',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<AppLocation?>(
      valueListenable: AppData().locationNotifier,
      builder: (context, location, _) {
        final locationText = location?.displayLabel ?? 'Select Location';

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            LocationPickerLauncher.open(context);
          },
          child: compact
              ? _CompactRow(theme: theme, locationText: locationText)
              : _FullRow(
                  theme: theme,
                  label: label,
                  locationText: locationText,
                ),
        );
      },
    );
  }
}

class _FullRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String locationText;

  const _FullRow({
    required this.theme,
    required this.label,
    required this.locationText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
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
    );
  }
}

class _CompactRow extends StatelessWidget {
  final ThemeData theme;
  final String locationText;

  const _CompactRow({required this.theme, required this.locationText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_rounded, size: 14, color: theme.primaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            locationText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}
