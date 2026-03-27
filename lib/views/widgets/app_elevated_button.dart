import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool? isEnabled;
  final bool isLoading;

  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 56, // Senior UX: slightly taller buttons
      child: ElevatedButton(
        onPressed: (isEnabled ?? true) && !isLoading ? onPressed : null,
        style: theme.elevatedButtonTheme.style,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
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
