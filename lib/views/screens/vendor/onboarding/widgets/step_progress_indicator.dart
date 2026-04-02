import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${((currentStep / totalSteps) * 100).toInt()}% Complete',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                decoration: BoxDecoration(
                  color: isActive ? theme.primaryColor : theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
