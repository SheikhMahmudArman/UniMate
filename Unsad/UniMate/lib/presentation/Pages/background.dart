import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundDecorationPainter(),
      size: Size.infinite,
    );
  }
}

class _BackgroundDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random();

    final paintDot = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final paintStar = Paint()
      ..color = Colors.yellow.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final paintLine = Paint()
      ..color = Colors.purple.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paintTriangle = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final paintCross = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final paintArc = Paint()
      ..color = Colors.orange.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final paintHexagon = Paint()
      ..color = Colors.pink.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final paintSmallCircle = Paint()
      ..color = Colors.teal.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Light background
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // More dots
    const double dotSpacing = 30.0;
    const double dotRadius = 3.0;
    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(
          Offset(x + random.nextDouble() * 15 - 7.5,
              y + random.nextDouble() * 15 - 7.5),
          dotRadius,
          paintDot,
        );
      }
    }

    // Stars
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 2.5, paintStar);
    }

    // Lines
    for (int i = 0; i < 20; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = x1 + (random.nextDouble() * 70 - 35);
      final y2 = y1 + (random.nextDouble() * 70 - 35);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paintLine);
    }

    // Triangles
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + 10, y + 20)
        ..lineTo(x - 10, y + 20)
        ..close();
      canvas.drawPath(path, paintTriangle);
    }

    // Crosses
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawLine(Offset(x - 4, y - 4), Offset(x + 4, y + 4), paintCross);
      canvas.drawLine(Offset(x + 4, y - 4), Offset(x - 4, y + 2), paintCross);
    }

    // Arcs
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final rect = Rect.fromCircle(center: Offset(x, y), radius: 12);
      canvas.drawArc(rect, 0, math.pi, false, paintArc);
    }

    // Hexagons
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final path = Path()
        ..moveTo(x, y - 8)
        ..lineTo(x + 6, y - 4)
        ..lineTo(x + 6, y + 4)
        ..lineTo(x, y + 8)
        ..lineTo(x - 6, y + 4)
        ..lineTo(x - 6, y - 4)
        ..close();
      canvas.drawPath(path, paintHexagon);
    }

    // Small circles
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 2.0, paintSmallCircle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
