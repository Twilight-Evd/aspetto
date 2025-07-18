import 'dart:math';

import 'package:flutter/material.dart';

class CircularPercentIndicator extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  const CircularPercentIndicator({
    super.key,
    required this.percent,
    required this.size,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularPercentIndicatorPainter(
          percent: percent,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
        ),
      ),
    );
  }
}

class _CircularPercentIndicatorPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularPercentIndicatorPainter({
    required this.percent,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw the background circle
    paint.color = backgroundColor;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width - strokeWidth) / 2,
      paint,
    );

    // Draw the progress circle
    paint.color = progressColor;
    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      -pi / 2,
      2 * pi * percent,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
