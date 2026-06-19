import 'package:flutter/material.dart';

class CropOverlayWidget extends StatefulWidget {
  final Size imageDisplaySize;
  final void Function(Rect cropRegion) onCropComplete;

  const CropOverlayWidget({
    super.key,
    required this.imageDisplaySize,
    required this.onCropComplete,
  });

  @override
  State<CropOverlayWidget> createState() => _CropOverlayWidgetState();
}

class _CropOverlayWidgetState extends State<CropOverlayWidget> {
  late Rect _cropRect;
  static const double _minSize = 50.0;

  @override
  void initState() {
    super.initState();
    _resetCropRect();
  }

  void _resetCropRect() {
    final w = widget.imageDisplaySize.width;
    final h = widget.imageDisplaySize.height;
    final cropW = w * 0.85;
    final cropH = h * 0.45;
    _cropRect = Rect.fromLTWH(
      (w - cropW) / 2,
      (h - cropH) / 2.5,
      cropW,
      cropH,
    );
  }

  Rect _clampRect(Rect rect) {
    final w = widget.imageDisplaySize.width;
    final h = widget.imageDisplaySize.height;
    return Rect.fromLTRB(
      rect.left.clamp(0, w - _minSize),
      rect.top.clamp(0, h - _minSize),
      rect.right.clamp(_minSize, w),
      rect.bottom.clamp(_minSize, h),
    );
  }

  void _onDragCorner(int corner, Offset delta) {
    setState(() {
      var r = _cropRect;
      switch (corner) {
        case 0: // top-left
          r = Rect.fromLTRB(r.left + delta.dx, r.top + delta.dy, r.right, r.bottom);
        case 1: // top-right
          r = Rect.fromLTRB(r.left, r.top + delta.dy, r.right + delta.dx, r.bottom);
        case 2: // bottom-left
          r = Rect.fromLTRB(r.left + delta.dx, r.top, r.right, r.bottom + delta.dy);
        case 3: // bottom-right
          r = Rect.fromLTRB(r.left, r.top, r.right + delta.dx, r.bottom + delta.dy);
      }
      _cropRect = _clampRect(r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        size: widget.imageDisplaySize,
        painter: _CropMaskPainter(cropRect: _cropRect),
        child: Stack(
          children: [
            // Invisible hit areas for the 4 corners
            _buildCornerHandle(0, _cropRect.topLeft),
            _buildCornerHandle(1, _cropRect.topRight),
            _buildCornerHandle(2, _cropRect.bottomLeft),
            _buildCornerHandle(3, _cropRect.bottomRight),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerHandle(int index, Offset pos) {
    const double handleSize = 80.0;
    return Positioned(
      left: pos.dx - (handleSize / 2),
      top: pos.dy - (handleSize / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => _onDragCorner(index, details.delta),
        onPanEnd: (_) => widget.onCropComplete(_cropRect),
        child: const SizedBox(
          width: handleSize,
          height: handleSize,
        ),
      ),
    );
  }
}

class _CropMaskPainter extends CustomPainter {
  final Rect cropRect;

  _CropMaskPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Perfectly round dark overlay using an even-odd path
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cropRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, overlayPaint);

    // Subtle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final rRect = RRect.fromRectAndRadius(cropRect, const Radius.circular(16));
    canvas.drawRRect(rRect, borderPaint);

    // Thick corners
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 32.0;
    const double radius = 16.0;

    // Top-Left
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.left, cropRect.top + cornerLength)
        ..lineTo(cropRect.left, cropRect.top + radius)
        ..quadraticBezierTo(cropRect.left, cropRect.top, cropRect.left + radius, cropRect.top)
        ..lineTo(cropRect.left + cornerLength, cropRect.top),
      cornerPaint,
    );
    // Top-Right
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.right - cornerLength, cropRect.top)
        ..lineTo(cropRect.right - radius, cropRect.top)
        ..quadraticBezierTo(cropRect.right, cropRect.top, cropRect.right, cropRect.top + radius)
        ..lineTo(cropRect.right, cropRect.top + cornerLength),
      cornerPaint,
    );
    // Bottom-Right
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.right, cropRect.bottom - cornerLength)
        ..lineTo(cropRect.right, cropRect.bottom - radius)
        ..quadraticBezierTo(cropRect.right, cropRect.bottom, cropRect.right - radius, cropRect.bottom)
        ..lineTo(cropRect.right - cornerLength, cropRect.bottom),
      cornerPaint,
    );
    // Bottom-Left
    canvas.drawPath(
      Path()
        ..moveTo(cropRect.left + cornerLength, cropRect.bottom)
        ..lineTo(cropRect.left + radius, cropRect.bottom)
        ..quadraticBezierTo(cropRect.left, cropRect.bottom, cropRect.left, cropRect.bottom - radius)
        ..lineTo(cropRect.left, cropRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_CropMaskPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect;
}
