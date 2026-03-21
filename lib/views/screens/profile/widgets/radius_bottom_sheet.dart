import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: AppSpacing.mediumVerticalSpacing(context)),
        Text(
          'Discovery Radius',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.smallVerticalSpacing(context)),
        Text(
          'Find vendors within ${_currentRadius.toInt()} miles',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
        Slider(
          value: _currentRadius,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: ColorName.primary,
          inactiveColor: ColorName.primary.withValues(alpha: 0.1),
          label: '${_currentRadius.toInt()} mi',
          onChanged: (value) {
            setState(() {
              _currentRadius = value;
            });
            widget.onRadiusChanged(value);
          },
        ),
        SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
      ],
    );
  }
}
