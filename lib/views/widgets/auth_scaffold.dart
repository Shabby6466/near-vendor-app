import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';

class AuthScaffold extends StatelessWidget {
  final Widget? body;
  final AppBar? appBar;
  final Color? bgColor;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final bool? resizeToAvoidBottomInset;
  final ImageProvider? backgroundImage;

  const AuthScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bgColor,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.extendBody = true,
    this.resizeToAvoidBottomInset,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    Widget mainBody = body ?? const SizedBox.shrink();

    // Use default background image if none is explicitly provided
    final bgImage = backgroundImage ?? Assets.images.itemsArt.provider();

    mainBody = Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: bgImage,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
        mainBody,
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: mainBody,
      appBar: appBar,
      extendBodyBehindAppBar: true,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
