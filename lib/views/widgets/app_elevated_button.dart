import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class AppElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isEnabled;
  final bool isLoading;

  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: theme.elevatedButtonTheme.style,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingAnimation(
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              )
            : Text(text),
      ),
    );
  }
}
