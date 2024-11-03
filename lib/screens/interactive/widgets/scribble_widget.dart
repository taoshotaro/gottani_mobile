import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/repositories/scratch_repository.dart';
import 'package:gottani_mobile/screens/interactive/widgets/floating_emoji.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:gottani_mobile/features/thermal.dart';
import 'package:gottani_mobile/repositories/message_emojis_repository.dart';
import 'package:gottani_mobile/screens/interactive/painter/glow_path_painter.dart';
import 'package:gottani_mobile/screens/interactive/widgets/comment_widget.dart';
import 'package:uuid/uuid.dart';

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
    final points = useState<Map<String, List<Offset>>>({});
    final shakeOffset = useState<Offset>(Offset.zero);
    final shouldAnimate = useState(false);
    final colors = useState<Map<String, Color>>({
      AppUuid.uuid: Color(0xFFFF4E4E),
    });

    final floatingEmojis = useState<List<Widget>>([]);

    void addFloatingEmoji(
      Offset position, {
      required String emojia,
      required String uuid,
    }) {
      final emojif = FloatingEmoji(
        key: ValueKey(uuid),
        position: position,
        emoji: emojia,
      );
      floatingEmojis.value = [...floatingEmojis.value, emojif];

      // Remove emoji after animation ends
      Future.delayed(const Duration(seconds: 2), () {
        floatingEmojis.value = floatingEmojis.value
            .where((e) => e != emojif)
            .toList(); // Remove completed animation
      });
    }

    final throttler = useState(ThermalThrottler(
      onScratchBegan: (offset, time, deltaHeat) {
        final emoji = ref.read(selectedEmojiProvider);

        unawaited(
          ref.read(messageEmojisRepositoryProvider).send(id, emoji),
        );
      },
      onScratchMoved: (offset, time, deltaHeat) async {
        final emoji = ref.read(selectedEmojiProvider);
        addFloatingEmoji(offset, emojia: emoji, uuid: Uuid().v1());

        unawaited(
          ref
              .read(scrachRepositoryProvider)
              .createScratch(id, offset.dx, offset.dy, emoji, deltaHeat, 1),
        );

        if (deltaHeat > 0.2) {
          shouldAnimate.value = true;
        } else {
          shouldAnimate.value = false;
        }
      },
      onScratchEnded: (offset, time, deltaHeat) {
        final emoji = ref.read(selectedEmojiProvider);

        shakeOffset.value = Offset.zero; // 振動を停止

        unawaited(
          ref
              .read(scrachRepositoryProvider)
              .createScratch(id, offset.dx, offset.dy, emoji, deltaHeat, 2),
        );
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

    void onLongPressCanceled() {
      throttler.value.cancel();

      shouldAnimate.value = false;

      scale.value = 1.0;
      points.value = {};
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

    // Remove scratch from id
    void removeScratch(String id) {
      points.value = {
        ...points.value,
        id: [],
      };
    }

    ref.listen(scratchStreamByMessageIdProvider(id).future, (_, scratch) {
      scratch.then((scratch) {
        if (!context.mounted) {
          return;
        }

        if (scratch.type == 2) {
          removeScratch(scratch.unique_id);
          return;
        }

        addFloatingEmoji(
          Offset(scratch.x, scratch.y),
          emojia: scratch.emoji,
          uuid: scratch.id,
        );

        final thisPoints = points.value[scratch.unique_id] ?? [];

        points.value = {
          ...points.value,
          scratch.unique_id: [
            ...thisPoints.length > 15
                ? thisPoints.sublist(thisPoints.length - 15)
                : thisPoints,
            Offset(scratch.x, scratch.y)
          ],
        };

        if (colors.value[scratch.unique_id] == null) {
          colors.value = {
            ...colors.value,
            scratch.unique_id: _generateRandomColor(),
          };
        }

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
            instance.onLongPressCancel = onLongPressCanceled;
          },
        ),
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScale(
            scale: scale.value,
            duration: const Duration(milliseconds: 200), // アニメーションの速度
            curve: Curves.easeOut, // アニメーションのカーブ
            child: ShakeRotationAnimation(
              shouldAnimate: shouldAnimate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentWidget(
                    text: content,
                    shadow: shouldAnimate.value,
                  ),
                  Gap(8),
                  ref.watch(messageEmojisStreamProvider(id)).when(
                        data: (emojis) => Row(
                          children:
                              emojis.map((emoji) => Text(emoji.emoji)).toList(),
                        ),
                        error: (error, stack) => Text(''),
                        loading: () => Text(''),
                      ),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: CustomPaint(
              painter: MultiGlowPathPainter(
                pointsMap: points.value,
                colors: colors.value,
              ),
            ),
          ),
          ...floatingEmojis.value,
        ],
      ),
    );
  }

  static Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1, // Set opacity to 0.5 for a glow effect
    );
  }
}

class ShakeRotationAnimation extends HookWidget {
  final Widget child;
  final Duration duration;
  final ValueNotifier<bool> shouldAnimate;

  const ShakeRotationAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    required this.shouldAnimate,
  });

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
