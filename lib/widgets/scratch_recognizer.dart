import 'package:flutter/material.dart';
import 'package:gottani_mobile/features/thermal.dart';

/// ユーザーからのスクラッチを認識するクラス
@immutable
class ScratchRecognizer extends StatefulWidget {
  const ScratchRecognizer({
    super.key,
    this.padding = EdgeInsets.zero,
    this.onScratchBegan,
    this.onScratchMoved,
    this.onScratchEnded,
    this.child,
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;

  final ScratchCallback? onScratchBegan;
  final ScratchCallback? onScratchMoved;
  final ScratchCallback? onScratchEnded;

  @override
  State<ScratchRecognizer> createState() => ScratchRecognizerState();
}

/// [ScratchRecognizer] の状態
class ScratchRecognizerState extends State<ScratchRecognizer> {
  late final ThermalThrottler _throttler;

  @override
  void initState() {
    super.initState();
    _throttler = ThermalThrottler(
      onScratchBegan: (offset, time, deltaHeat) =>
          widget.onScratchBegan?.call(offset, time, deltaHeat),
      onScratchMoved: (offset, time, deltaHeat) =>
          widget.onScratchMoved?.call(offset, time, deltaHeat),
      onScratchEnded: (offset, time, deltaHeat) =>
          widget.onScratchEnded?.call(offset, time, deltaHeat),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _throttler.start(details.localPosition, ThermalTime.now());
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _throttler.move(details.localPosition, ThermalTime.now());
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _throttler.end(details.localPosition, ThermalTime.now());
  }
}
