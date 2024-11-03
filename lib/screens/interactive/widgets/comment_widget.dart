import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    this.shadow = false,
    required this.text,
  });

  final bool shadow;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 32,
      ),
      decoration: BoxDecoration(
        color: shadow ? Color(0xffFFE1DA) : Colors.white,
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
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
