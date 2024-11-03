import 'package:flutter/material.dart';

@immutable
class Emoji extends StatelessWidget {
  const Emoji(
    this.text, {
    super.key,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontFamily: 'Emoji').merge(style),
    );
  }
}
