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
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 56, // Senior UX: slightly taller buttons
      child: ElevatedButton(
        onPressed: (isEnabled ?? true) ? onPressed : null,
        style: theme.elevatedButtonTheme.style,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
