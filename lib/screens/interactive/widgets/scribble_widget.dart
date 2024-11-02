import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/features/thermal.dart';
import 'package:gottani_mobile/screens/interactive/painter/glow_path_painter.dart';

class ScribbleWidget extends HookWidget {
  const ScribbleWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scale = useState<double>(1);
    final points = useState<List<Offset>>([]);

    final throttler = useState(ThermalThrottler(
      onScratchBegan: (offset, time, deltaHeat) {},
      onScratchMoved: (offset, time, deltaHeat) {
        debugPrint("DEBUG: offset $offset time $time deltaHeat $deltaHeat");
      },
      onScratchEnded: (offset, time, deltaHeat) {},
    ));

    void onLongPressStart(LongPressStartDetails details) {
      throttler.value.start(details.localPosition, ThermalTime.now());

      HapticFeedback.lightImpact();
      scale.value = 1.2;
    }

    void onLongPressEnd(LongPressEndDetails details) {
      throttler.value.end(details.localPosition, ThermalTime.now());

      scale.value = 1.0;
      points.value = [];
    }

    void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
      throttler.value.move(details.localPosition, ThermalTime.now());

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
