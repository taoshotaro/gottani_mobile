import 'package:flutter/material.dart';
import 'dart:math';

class GlowPathPainter extends CustomPainter {
  final Map<String, List<Offset>> pointsMap;
  final List<Color> colors;

  GlowPathPainter(this.pointsMap)
      : colors = List<Color>.generate(
          pointsMap.length,
          (index) => _generateRandomColor(),
        );

  static Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1, // Set opacity to 0.5 for a glow effect
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Iterate over each list of points and draw a path for each set with a unique color
    for (final (index, points) in pointsMap.values.indexed) {
      if (points.isEmpty) continue;

      final paint = Paint()
        // ..color = colors[index]
        ..color = Colors.red
        ..strokeWidth = 15.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(points[0].dx, points[0].dy);

      for (var point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, paint);
      // index++; // Move to the next color
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


// class GlowPathPainter extends CustomPainter {
//   final List<Offset> points;

//   GlowPathPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (points.isEmpty) return;

//     final paint = Paint()
//       ..color = Color.fromARGB(255, 255, 78, 78) // 線の色と透明度
//       ..strokeWidth = 15.0 // 線の太さ
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//     // ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.0); // ぼかし効果

//     for (int i = 0; i < points.length - 1; i++) {
//       canvas.drawLine(points[i], points[i + 1], paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // パスが更新されるたびに再描画
//   }
// }
