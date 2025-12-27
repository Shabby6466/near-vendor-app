import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled,
  });

  final void Function()? onPressed;
  final String text;
  final bool? isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? null,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isEnabled == true
                ? Colors.black
                : Colors.black.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
