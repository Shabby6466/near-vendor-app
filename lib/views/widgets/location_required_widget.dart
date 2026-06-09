import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/navigation/location_picker_launcher.dart';
import 'package:nearvendorapp/views/widgets/app_animate_list.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class LocationRequiredWidget extends StatelessWidget {
  final VoidCallback? onLocationSet;
  final String title;
  final String description;
  final String buttonText;

  const LocationRequiredWidget({
    super.key,
    this.onLocationSet,
    this.title = 'Location Not Set',
    this.description = 'Please set your location to discover nearby local vendors and shops.',
    this.buttonText = 'Set Location',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AppAnimateList.stagger([
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 64,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppElevatedButton(
                text: buttonText.toUpperCase(),
                onPressed: () async {
                  final result = await LocationPickerLauncher.open(context);
                  if (result != null && onLocationSet != null) {
                    onLocationSet!();
                  }
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
