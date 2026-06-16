import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class AppElevatedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isEnabled;
  final bool isLoading;
  final Color? color;

  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isEnabled = true,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).primaryColor;
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.light
        ? Colors.black87
        : Colors.white;

    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: foregroundColor,
      ),
      child: isLoading ? LoadingAnimation(color: foregroundColor) : Text(text),
    );
  }
}
