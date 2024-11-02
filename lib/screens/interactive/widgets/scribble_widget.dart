import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/repositories/scratch_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gottani_mobile/features/thermal.dart';
import 'package:gottani_mobile/screens/interactive/painter/glow_path_painter.dart';
import 'package:gottani_mobile/screens/interactive/widgets/comment_widget.dart';

class ScribbleWidget extends HookConsumerWidget {
  const ScribbleWidget({
    super.key,
    required this.id,
    required this.content,
    required this.initialHeat,
  });

  final String id;
  final String content;
  final double initialHeat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = useState<double>(1);
    // final points = useState<List<Offset>>([]);
    final points = useState<Map<String, List<Offset>>>({});
    final shakeOffset = useState<Offset>(Offset.zero);
    final shouldAnimate = useState(false);

    final throttler = useState(ThermalThrottler(
      onScratchBegan: (offset, time, deltaHeat) {},
      onScratchMoved: (offset, time, deltaHeat) async {
        unawaited(
          ref.read(scrachRepositoryProvider).createScratch(
                id,
                offset.dx,
                offset.dy,
                '❤️',
                deltaHeat,
              ),
        );

        if (deltaHeat > 0.2) {
          shouldAnimate.value = true;
        } else {
          shouldAnimate.value = false;
        }
      },
      onScratchEnded: (offset, time, deltaHeat) {
        shakeOffset.value = Offset.zero; // 振動を停止
      },
    ));

    void onLongPressStart(LongPressStartDetails details) {
      throttler.value.start(details.localPosition, ThermalTime.now());

      HapticFeedback.lightImpact();
      scale.value = 1.2;
    }

    void onLongPressEnd(LongPressEndDetails details) {
      throttler.value.end(details.localPosition, ThermalTime.now());

      shouldAnimate.value = false;

      scale.value = 1.0;
      points.value = {
        ...points.value,
        AppUuid.uuid: [],
      };
      shakeOffset.value = Offset.zero;
    }

    void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
      throttler.value.move(details.localPosition, ThermalTime.now());

      final myPoints = points.value[AppUuid.uuid] ?? [];

      points.value = {
        ...points.value,
        AppUuid.uuid: [
          ...myPoints.length > 80
              ? myPoints.sublist(myPoints.length - 80)
              : myPoints,
          details.localPosition
        ],
      };

      // points.value = [
      //   ...points.value.length > 80
      //       ? points.value.sublist(points.value.length - 80)
      //       : points.value,
      //   details.localPosition
      // ];
    }

    ref.listen(scratchStreamByMessageIdProvider(id).future, (_, scratch) {
      scratch.then((scratch) {
        if (!context.mounted) {
          return;
        }

        final thisPoints = points.value[scratch.unique_id] ?? [];

        points.value = {
          ...points.value,
          scratch.unique_id: [
            ...thisPoints.length > 80
                ? thisPoints.sublist(thisPoints.length - 80)
                : thisPoints,
            Offset(scratch.x, scratch.y)
          ],
        };

        // points.value = [
        //   ...points.value.length > 80
        //       ? points.value.sublist(points.value.length - 80)
        //       : points.value,
        //   Offset(scratch.x, scratch.y)
        // ];
        // messageWidgets.add(
        //   _PositionedScribbleWidget(
        //     key: ValueKey(message.id),
        //     message: message,
        //   ),
        // );
        // setState(() {});
      });
    });

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
      child: Stack(
        children: [
          AnimatedScale(
            scale: scale.value,
            duration: const Duration(milliseconds: 200), // アニメーションの速度
            curve: Curves.easeOut, // アニメーションのカーブ
            child: ShakeRotationAnimation(
              shouldAnimate: shouldAnimate,
              child: CommentWidget(
                text: content,
                shadow: shouldAnimate.value,
              ),
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: CustomPaint(
              painter: GlowPathPainter(points.value),
            ),
          ),
        ],
      ),
    );
  }
}

class ShakeRotationAnimation extends HookWidget {
  final Widget child;
  final Duration duration;
  final ValueNotifier<bool> shouldAnimate;

  const ShakeRotationAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    required this.shouldAnimate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(milliseconds: 100),
      initialValue: Random().nextDouble(),
    );
    final animation = useMemoized(
      () => Tween<double>(begin: -0.1, end: 0.1)
          .chain(CurveTween(curve: Curves.linear))
          .animate(controller),
      [controller],
    );

    useEffect(() {
      if (shouldAnimate.value && !controller.isAnimating) {
        controller.repeat(reverse: true);
      } else {
        controller.stop();
      }
      return null;
    }, [shouldAnimate.value]);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value, // 少し回転
          child: this.child,
        );
      },
      child: child,
    );
  }
}
