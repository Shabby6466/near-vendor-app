import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/theme/app_spacing.dart';

class RadiusBottomSheet extends StatefulWidget {
  final double initialRadius;
  final ValueChanged<double> onRadiusChanged;

  const RadiusBottomSheet({
    super.key,
    required this.initialRadius,
    required this.onRadiusChanged,
  });

  @override
  State<RadiusBottomSheet> createState() => _RadiusBottomSheetState();
}

class _RadiusBottomSheetState extends State<RadiusBottomSheet> {
  late double _currentRadius;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        Text(
          'Discovery Radius',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        Text(
          'Find vendors within ${_currentRadius.toInt()} kilometers',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: AppSpacing.extraLargeVerticalSpacing(context)),
        Slider(
          value: _currentRadius,
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: theme.primaryColor,
          inactiveColor: theme.primaryColor.withValues(alpha: 0.1),
          label: '${_currentRadius.toInt()} km',
          onChanged: (value) {
            setState(() {
              _currentRadius = value;
            });
            widget.onRadiusChanged(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km', style: theme.textTheme.labelSmall),
              Text('100 km', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
      ],
    );
  }
}
