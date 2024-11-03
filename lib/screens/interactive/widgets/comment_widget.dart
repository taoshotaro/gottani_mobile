import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:gottani_mobile/screens/interactive/widgets/whiteout_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';

class CommentWidget extends HookWidget {
  const CommentWidget({
    super.key,
    this.shadow = false,
    required this.text,
    this.isFire = true, // trueにすると爆発する
  });

  final bool shadow;
  final String text;
  final bool isFire;

  @override
  Widget build(BuildContext context) {
    final shadowElapsed = useState(0.0);
    final firstRedShadowSpreadRadius = useState(0.0);
    final secondWhiteShadowSpreadRadius = useState(0.0);
    final secondWhiteShadowWhiting = useState(0);

    useEffect(() {
      if (!isFire) return null;
      if (!shadow) {
        shadowElapsed.value = 0;
        return null;
      }
      final timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        shadowElapsed.value += 1;
      });

      return timer.cancel;
    }, [shadow]);

    useEffect(() {
      if (!shadow) {
        firstRedShadowSpreadRadius.value = 0;
        secondWhiteShadowSpreadRadius.value = 0;
        if (secondWhiteShadowWhiting.value != 0) {
          Future.delayed(Duration(milliseconds: 100), () {
            secondWhiteShadowWhiting.value = 0;
          });
        }
        return null;
      }

      firstRedShadowSpreadRadius.value += 8;

      final delay = 4;
      if (shadowElapsed.value > delay) {
        secondWhiteShadowSpreadRadius.value += 5;
        if (secondWhiteShadowWhiting.value > 255) return;
        secondWhiteShadowWhiting.value += 8;
      }

      final lastWhiteOutDelay = 30;
      if (shadowElapsed.value > lastWhiteOutDelay) {
        Future(() async {
          await ScreenBrightness().setApplicationScreenBrightness(1);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            useSafeArea: false,
            builder: (_) => WhiteoutDialog(),
          );
        });
        Future(() async {
          for (int i = 0; i < 90; i++) {
            await Future.delayed(Duration(milliseconds: 10));
            HapticFeedback.heavyImpact();
          }
          await ScreenBrightness().resetApplicationScreenBrightness();
        });
      }
      return null;
    }, [shadowElapsed.value]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 32,
          ),
          decoration: BoxDecoration(
            // color: shadow ? Color(0xffFFE1DA) : Colors.white,
            color: Color.fromRGBO(255, 255 - secondWhiteShadowWhiting.value,
                255 - secondWhiteShadowWhiting.value, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              if (shadow)
                BoxShadow(
                  color: Color(0xffD24148), // 影の色と透明度
                  spreadRadius: firstRedShadowSpreadRadius.value, // 影の広がり具合
                  blurRadius: 200, // 影のぼかし具合
                  offset: Offset(0, 0), // 影の位置（x方向、y方向）
                ),
              if (shadow)
                BoxShadow(
                  color: Color.fromRGBO(
                    255,
                    secondWhiteShadowWhiting.value,
                    secondWhiteShadowWhiting.value,
                    1,
                  ), // 影の色と透明度
                  spreadRadius: secondWhiteShadowSpreadRadius.value,
                  blurRadius: 200, // 影のぼかし具合
                  offset: Offset(0, 0), // 影の位置（x方向、y方向）
                ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Gap(8),
        Row(
          children: [
            Text("😎"),
            Text("❤️"),
            Text("🤘"),
            Text("🔥"),
          ],
        ),
      ],
    );
  }
}
