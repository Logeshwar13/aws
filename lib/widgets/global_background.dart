import 'dart:ui' as ui;
import 'package:flutter/material.dart';


class _GridPainter extends CustomPainter {
  final Color lineColor;
  final Color majorLineColor;
  final double spacing;
  final double majorSpacing;

  _GridPainter({
    this.lineColor = const Color(0xFFFFFFFF),
    this.majorLineColor = const Color(0xFFFFFFFF),
    this.spacing = 48.0,
    this.majorSpacing = 240.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = lineColor
      ..isAntiAlias = true;

    final Paint majorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = majorLineColor
      ..isAntiAlias = true;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height),
          (x % majorSpacing == 0) ? majorPaint : paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          (y % majorSpacing == 0) ? majorPaint : paint);
    }

    final rect = Offset.zero & size;
    final shader = ui.Gradient.radial(
      size.center(Offset.zero),
      (size.width > size.height ? size.width : size.height) * 0.7,
      [Colors.transparent, Colors.black.withOpacity(0.50)],
      [0.6, 1.0],
    );
    canvas.drawRect(
        rect, Paint()..shader = shader..blendMode = BlendMode.darken);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.majorLineColor != majorLineColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.majorSpacing != majorSpacing;
  }
}

class GlobalBackground extends StatelessWidget {
  const GlobalBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/neonBac.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GridPainter(
                lineColor: Colors.white.withOpacity(0.15),
                majorLineColor: Colors.white.withOpacity(0.25),
                spacing: 48,
                majorSpacing: 240,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF071A3A).withOpacity(0.45),
                  const Color(0xFF071A3A).withOpacity(0.65),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
