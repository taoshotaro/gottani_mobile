import 'package:flutter/foundation.dart';
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
    final style = kIsWeb
        ? const TextStyle(fontFamily: 'Emoji').merge(this.style)
        : this.style;

    return Text(
      text,
      style: style,
    );
  }
}
