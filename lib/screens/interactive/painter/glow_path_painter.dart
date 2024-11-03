import 'package:flutter/material.dart';
// import 'dart:math';

class MultiGlowPathPainter extends CustomPainter {
  final Map<String, List<Offset>> pointsMap;
  final Map<String, Color> colors;

  MultiGlowPathPainter({
    required this.pointsMap,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Iterate over each list of points and draw a path for each set with a unique color

    for (var entry in pointsMap.entries) {
      final key = entry.key;
      final points = entry.value;
      if (points.isEmpty) continue;

      final paint = Paint()
        ..color = colors[key] ?? Color.fromRGBO(255, 255, 255, 0.5)
        // ..blendMode = BlendMode.overlay
        ..strokeWidth = 15.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length - 2; i++) {
        var p0 = points[i - 1];
        var p1 = points[i];
        var p2 = points[i + 1];
        var p3 = points[i + 2];

        // Control points using Catmull-Rom splines
        var cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) * 0.2,
          p1.dy + (p2.dy - p0.dy) * 0.2,
        );
        var cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) * 0.2,
          p2.dy - (p3.dy - p1.dy) * 0.2,
        );

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }

      // Draw the final segment to the last point
      path.lineTo(points.last.dx, points.last.dy);

      canvas.drawPath(path, paint);
      // index++; // Move to the next color
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GlowPathPainter extends CustomPainter {
  final List<Offset> points;

  GlowPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Color.fromARGB(255, 255, 78, 78) // 線の色と透明度
      ..blendMode = BlendMode.plus
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
