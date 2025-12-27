import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
// import 'package:nearvendorapp/gen/assets.gen.dart';

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final AppBar? appBar;
  final MaterialColor? bgColor;
  final Widget? bottomNavigationBar;
  // final AssetGenImage? backgroundImage;
  final bool extendBodyBehindAppBar;
  final bool extendBody;

  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.bgColor,
    // this.backgroundImage,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bgColor ?? ColorName.primary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image(
          //   image:
          //       backgroundImage?.provider() ??
          //       Assets.images.scaffoldBg.provider(),
          //   fit: BoxFit.cover,
          // ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: body,
            appBar: appBar,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            extendBody: extendBody,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ],
      ),
    );
  }
}
