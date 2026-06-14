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
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? LoadingAnimation(color: Theme.of(context).colorScheme.primary)
          : Text(text),
    );
  }
}
