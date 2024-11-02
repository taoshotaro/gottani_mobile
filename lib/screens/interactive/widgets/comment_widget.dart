import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key, this.shadow = false});

  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 32,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              if (shadow)
                BoxShadow(
                  color: Color(0xffD24148), // 影の色と透明度
                  spreadRadius: 10, // 影の広がり具合
                  blurRadius: 40, // 影のぼかし具合
                  offset: Offset(0, 0), // 影の位置（x方向、y方向）
                ),
            ],
          ),
          child: Text(
            "告られた",
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
