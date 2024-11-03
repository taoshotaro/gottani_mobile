import 'package:flutter/material.dart';

class FloatingEmoji extends StatefulWidget {
  final Offset position;
  final String emoji;

  const FloatingEmoji({
    Key? key,
    required this.position,
    required this.emoji,
  }) : super(key: key);

  @override
  _FloatingEmojiState createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _positionAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -10), // Adjusted to float slightly upward
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: IgnorePointer(
        child: SlideTransition(
          position: _positionAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              widget.emoji, // Emoji to display
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
