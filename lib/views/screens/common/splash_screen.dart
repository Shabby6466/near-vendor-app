import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:path_drawing/path_drawing.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextRoute;
  final Color logoColor;

  const SplashScreen({
    super.key,
    required this.nextRoute,
    this.logoColor = ColorName.primary,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _zoomController;
  late AnimationController _fadeNextRouteController;

  late Animation<double> _drawAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _fadeNextRouteAnimation;

  final String svgPath =
      "M150.73 267.09 c0 -0.13 2.91 -3.61 6.48 -7.76 8.69 -10.12 11.14 -13.03 14.15 -16.80 13.67 -17.12 21.91 -35.70 25.64 -57.80 2.78 -16.48 2.46 -36.76 -0.77 -49.66 -3.74 -14.98 -10.28 -26.35 -19.93 -34.55 -10.25 -8.69 -22.70 -14.02 -35.80 -15.26 -9.55 -0.93 -20.95 1.53 -31.42 6.77 -22.96 11.50 -34.01 31.90 -34.90 64.44 -0.51 19 2.97 39.47 10.41 61.41 2.84 8.33 7.31 19.32 10.09 24.84 l0.83 1.60 -2.65 1.25 c-1.47 0.67 -6.23 2.94 -10.63 5.05 -4.37 2.11 -8.08 3.77 -8.18 3.70 -0.13 -0.06 -1.37 -2.68 -2.78 -5.81 -18.68 -41.26 -25.20 -82.39 -18.43 -116.21 2.59 -12.84 7.89 -25.77 14.47 -35.22 12.10 -17.37 32 -29.73 55.21 -34.36 3.07 -0.61 15.74 -1.21 19.93 -0.96 9.84 0.61 21.17 3.90 31.58 9.16 28.64 14.47 44.61 39.79 48.06 76.29 0.77 7.76 0.51 23.57 -0.45 31.71 -2.30 19.22 -6.77 35.35 -13.80 50.01 -1.21 2.52 -2.14 4.66 -2.08 4.73 0.22 0.22 8.11 -3.90 11.24 -5.84 12.65 -7.89 23.09 -19.93 28.87 -33.21 2.87 -6.61 4.66 -12.84 5.91 -20.72 0.70 -4.28 0.99 -15.58 0.51 -20.34 -1.47 -15.20 -6.58 -29.99 -14.88 -43.05 -0.73 -1.15 -1.41 -2.24 -1.53 -2.43 -0.13 -0.19 2.75 -2.40 7.15 -5.43 4.02 -2.78 8.30 -5.75 9.48 -6.58 1.15 -0.86 2.30 -1.53 2.49 -1.53 0.45 0 4.09 5.84 7.09 11.34 6.61 12.20 10.99 25.16 13.06 38.80 0.83 5.24 0.86 6.29 0.89 16.61 0 10 -0.06 11.46 -0.77 15.97 -2.33 15.39 -7.63 29.38 -15.74 41.51 -4.34 6.55 -6.64 9.32 -12.68 15.36 -11.40 11.37 -24.24 19.26 -40.52 24.88 -12.87 4.47 -25.74 6.51 -49.88 7.98 -6.26 0.38 -5.75 0.35 -5.75 0.13z";

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _drawController, curve: Curves.easeInOut),
    );

    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 120.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOutCubic),
    );

    _fadeNextRouteController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeNextRouteAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fadeNextRouteController);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _drawController.forward();

    await Future.delayed(const Duration(milliseconds: 200));

    _zoomController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _fadeNextRouteController.forward();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.nextRoute,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    _zoomController.dispose();
    _fadeNextRouteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IgnorePointer(
        ignoring: _fadeNextRouteController.value > 0.8,
        child: FadeTransition(
          opacity: ReverseAnimation(_fadeNextRouteAnimation),
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_drawController, _zoomController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: PathPainter(
                      pathString: svgPath,
                      progress: _drawAnimation.value,
                      logoColor: widget.logoColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final String pathString;
  final double progress;
  final Color logoColor;

  PathPainter({
    required this.pathString,
    required this.progress,
    required this.logoColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(pathString);
    final pathBounds = path.getBounds();

    final scale = size.width / pathBounds.width;
    final Matrix4 matrix = Matrix4.diagonal3Values(scale, scale, 1)
      ..setEntry(0, 3, -pathBounds.left)
      ..setEntry(1, 3, -pathBounds.top);

    final transformedPath = path.transform(matrix.storage);

    final scaledBounds = transformedPath.getBounds();
    final dx = (size.width - scaledBounds.width) / 2;
    final dy = (size.height - scaledBounds.height) / 2;
    final centeredPath = transformedPath.shift(Offset(dx, dy));

    if (progress < 1.0) {
      final strokePaint = Paint()
        ..color = logoColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(_createAnimatedPath(centeredPath, progress), strokePaint);
    }

    if (progress > 0.8) {
      final fillOpacity = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
      canvas.drawPath(
        centeredPath,
        Paint()
          ..color = Color.fromRGBO(
            (logoColor.r * 255).round(),
            (logoColor.g * 255).round(),
            (logoColor.b * 255).round(),
            logoColor.a * fillOpacity,
          ),
      );
    }
  }

  Path _createAnimatedPath(Path source, double animationPercent) {
    final Path dest = Path();
    for (final metric in source.computeMetrics()) {
      dest.addPath(
        metric.extractPath(0, metric.length * animationPercent),
        Offset.zero,
      );
    }
    return dest;
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;
}
