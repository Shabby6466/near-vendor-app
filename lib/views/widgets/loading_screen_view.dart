import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';

class LoadingScreenView extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingScreenView({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: Center(
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.05),
                      offset: const Offset(0.0, 20.0),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const LoadingAnimation(),
              ),
            ),
          ),
      ],
    );
  }
}
