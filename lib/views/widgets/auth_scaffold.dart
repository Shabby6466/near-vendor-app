import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';

class AuthScaffold extends StatelessWidget {
  final Widget? body;
  final AppBar? appBar;
  final Color? bgColor;
  final ImageProvider? backgroundImage;

  const AuthScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bgColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor ?? Theme.of(context).primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: backgroundImage ?? Assets.images.itemsArt.provider(),
            fit: BoxFit.cover,
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
    );
  }
}
