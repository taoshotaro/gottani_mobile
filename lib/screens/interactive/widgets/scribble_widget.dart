import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/screens/interactive/painter/glow_path_painter.dart';

class ScribbleWidget extends HookWidget {
  const ScribbleWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scale = useState<double>(1);
    final points = useState<List<Offset>>([]);

    void onLongPressStart(LongPressStartDetails details) {
      HapticFeedback.lightImpact();
      scale.value = 1.2;
    }

    void onLongPressEnd(LongPressEndDetails details) {
      scale.value = 1.0;
      points.value = [];
    }

    void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
      points.value = [...points.value, details.localPosition];
    }

    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(
            debugOwner: this,
            duration: Duration(milliseconds: 150),
          ),
          (LongPressGestureRecognizer instance) {
            instance.onLongPressStart = onLongPressStart;
            instance.onLongPressEnd = onLongPressEnd;
            instance.onLongPressMoveUpdate = onLongPressMoveUpdate;
          },
        ),
      },
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 200), // アニメーションの速度
        curve: Curves.easeOut, // アニメーションのカーブ
        child: Stack(
          children: [
            if (child != null) child!,
            Opacity(
              opacity: 0.5,
              child: CustomPaint(
                painter: GlowPathPainter(points.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
