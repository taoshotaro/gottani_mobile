import 'package:flutter/material.dart';

class MultiGlowPathPainter extends CustomPainter {
  final Map<String, List<Offset>> pointsMap;
  final Map<String, Color> colors;

  MultiGlowPathPainter({
    required this.pointsMap,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

      path.lineTo(points.last.dx, points.last.dy);

      canvas.drawPath(path, paint);
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
      ..color = Color.fromARGB(255, 255, 78, 78)
      ..blendMode = BlendMode.plus
      ..strokeWidth = 15.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
