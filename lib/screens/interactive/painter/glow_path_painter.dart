import 'package:flutter/material.dart';

class GlowPathPainter extends CustomPainter {
  final List<Offset> points;

  GlowPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Color.fromARGB(255, 255, 78, 78) // 線の色と透明度
      ..strokeWidth = 15.0 // 線の太さ
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0); // ぼかし効果

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // パスが更新されるたびに再描画
  }
}
