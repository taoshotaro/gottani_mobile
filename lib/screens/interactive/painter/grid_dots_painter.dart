import 'package:flutter/material.dart';

class GridDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xff4d4d4d)
      ..style = PaintingStyle.fill;

    const double spacing = 46.0; // 点間の間隔
    const double radius = 2.0; // 点の半径

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        // canvas.draw
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
