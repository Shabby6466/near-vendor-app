import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discovery Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context,
                icon: Icons.location_searching,
                title: 'Discovery Radius',
                subtitle: 'Find vendors within ${radius.toInt()} miles',
                trailing: Text(
                  '${radius.toInt()} mi',
                  style: const TextStyle(
                    color: ColorName.primary,
                    fontWeight: FontWeight.bold,
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
              const Divider(),
              _buildSettingItem(
                context,
                icon: Icons.notifications_none,
                title: 'New Offer Alerts',
                subtitle: 'Notifications from nearby shops',
                trailing: Switch(
                  value: newOfferAlerts,
                  onChanged: onAlertsToggled,
                  activeThumbColor: ColorName.primary,
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorName.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorName.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
