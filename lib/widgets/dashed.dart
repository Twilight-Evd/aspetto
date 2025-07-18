import 'dart:ui';

import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  final double radius; // 圆角半径
  final Color color; // 边框颜色

  final double strokeWidth; // 边框宽度
  final double dashWidth; // 定义虚线的长度和间隔
  final double dashSpace;

  DashedBorderPainter(
      {this.color = Colors.blue,
      this.radius = 0,
      this.strokeWidth = 1,
      this.dashWidth = 3,
      this.dashSpace = 3});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color // 边框颜色
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 创建一个圆角矩形的路径
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // 绘制虚线边框
    drawDashedLine(canvas, rrect, paint, dashWidth, dashSpace);
  }

  void drawDashedLine(Canvas canvas, RRect rrect, Paint paint, double dashWidth,
      double dashSpace) {
    // 创建一个圆角矩形路径
    final Path path = Path()..addRRect(rrect);
    final List<Offset> points = [];
    // 获取路径上的所有点
    for (PathMetric pathMetric in path.computeMetrics()) {
      for (double i = 0; i < pathMetric.length; i += dashWidth + dashSpace) {
        points.add(pathMetric.getTangentForOffset(i)?.position ?? Offset.zero);
      }
    }
    // 绘制虚线
    for (int i = 0; i < points.length - 1; i++) {
      if (i % 2 == 0) {
        // 只绘制虚线部分
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
