import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_bottom_sheet.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/profile/widgets/radius_bottom_sheet.dart';

class DiscoverySettings extends StatelessWidget {
  final double radius;
  final bool newOfferAlerts;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<bool> onAlertsToggled;

  const DiscoverySettings({
    super.key,
    required this.radius,
    required this.newOfferAlerts,
    required this.onRadiusChanged,
    required this.onAlertsToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovery Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: (0.05)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: Icons.location_searching_rounded,
                title: 'Discovery Radius',
                subtitle: 'Find vendors within ${radius.toInt()} kilometers',
                trailing: Text(
                  '${radius.toInt()} km',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                onTap: () {
                  AppBottomSheet.showBottomSheet(
                    context: context,
                    child: RadiusBottomSheet(
                      initialRadius: radius,
                      onRadiusChanged: onRadiusChanged,
                    ),
                  );
                },
              ),
              Divider(
                height: 32,
                color: theme.dividerColor.withValues(alpha: (0.1)),
              ),
              _buildSettingItem(
                context,
                icon: Icons.notifications_active_outlined,
                title: 'New Offer Alerts',
                subtitle: 'Notifications from nearby shops',
                trailing: Switch(
                  value: newOfferAlerts,
                  onChanged: onAlertsToggled,
                  activeThumbColor: theme.primaryColor,
                  activeTrackColor: theme.primaryColor.withValues(alpha: (0.3)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: (0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: (0.6),
                      ),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
