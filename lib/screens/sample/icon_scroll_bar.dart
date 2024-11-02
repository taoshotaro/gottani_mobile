import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math' as math;

class IconScrollBar extends HookWidget {
  const IconScrollBar({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(viewportFraction: 0.21);

    final emojiArr = [
      '👍',
      '🔥',
      '🎉',
      '👏',
      '😎',
      '🥰',
      '😍',
    ];

    double calculateEmojiScale(int index, double position) {
      if ((index.toDouble() - position).abs() >= 1.0) {
        return 1.0;
      } else {
        double diff = (index.toDouble() - position).abs();
        double rv = 1.0 * ((1.0 - diff).abs() + 0.2);
        if (rv < 1.0) {
          return 1.0;
        } else {
          return rv;
        }
      }
    }

    double calculateEmojiOpacity(int index, double position) {
      if ((index.toDouble() - position).abs() >= 1.0) {
        return 0.3;
      } else {
        double diff = (1.0 - (index.toDouble() - position).abs()) * 0.4;
        return 0.3 + diff;
      }
    }

    final position = useState(0.0);

    controller.addListener(() {
      double previousValue = position.value % 1;
      double currentValue = (controller.page ?? 0.0) % 1;
      position.value = controller.page ?? 0.0;

      debugPrint('previousValue: $previousValue');
      debugPrint('currentValue: $currentValue');

      if (previousValue != 0.0 && currentValue != 0.0) {
        if (previousValue < 0.5 && currentValue >= 0.5) {
          // HapticFeedback.heavyImpact();
          return;
        } else if (previousValue > 0.5 && currentValue <= 0.5) {
          // HapticFeedback.heavyImpact();
          return;
        }
      }
    });

    return Stack(
      children: [
        Center(
            child: Container(
          height: 50,
          color: Colors.white,
        )),
        SizedBox(
          width: double.infinity,
          height: 100,
          child: PageView(
            controller: controller,
            children: emojiArr.indexed.map(
              (entry) {
                int index = entry.$1;
                String emoji = entry.$2;
                return Transform.scale(
                  scale: calculateEmojiScale(index, position.value) - 0.35,
                  child: ColoredBox(
                    color:
                        Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(0.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            color: const Color(0xFF1D1D1D).withOpacity(
                                calculateEmojiOpacity(
                                    index, position.value)), // 小さい方は30%
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Stack(
                            children: [
                              ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 40.0, sigmaY: 40.0),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.0),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  emoji,
                                  style: TextStyle(
                                    fontSize: 54.0 *
                                        calculateEmojiScale(
                                            index, position.value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
