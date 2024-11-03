import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/widgets/emoji.dart';

class IconScrollBar extends HookWidget {
  const IconScrollBar({
    super.key,
    required this.onEmojiSelected,
  });

  final Function(String) onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    final PageController controller =
        PageController(viewportFraction: 0.21, initialPage: 3);

    final emojiArr = [
      '👍',
      '🎉',
      '👏',
      '🔥',
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

    final position = useState(3.0);
    final currentPage = useState(3);

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

      double currentPage = controller.page ?? 0.0;
    });

    return SizedBox(
      width: double.infinity,
      height: 100,
      child: PageView(
        controller: controller,
        onPageChanged: (index) {
          final emoji = emojiArr[index];

          onEmojiSelected(emoji);
        },
        children: emojiArr.indexed.map(
          (entry) {
            int index = entry.$1;
            String emoji = entry.$2;
            return GestureDetector(
              onTap: () {
                controller.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Transform.scale(
                scale: calculateEmojiScale(index, position.value) - 0.35,
                child: ColoredBox(
                  color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
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
                              child: Emoji(
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
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
