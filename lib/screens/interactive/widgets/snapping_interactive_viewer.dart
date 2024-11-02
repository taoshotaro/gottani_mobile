import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class SnappingInteractiveViewer extends StatefulWidget {
  final Widget child;
  final double gridSize;

  SnappingInteractiveViewer(
      {super.key, required this.child, this.gridSize = 46.0});

  @override
  _SnappingInteractiveViewerState createState() =>
      _SnappingInteractiveViewerState();
}

class _SnappingInteractiveViewerState extends State<SnappingInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _controller;
  late final double _gridSize;
  Offset _lastSnappedPosition = Offset.zero;

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _gridSize = widget.gridSize;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    print("DEBUGG: _onInteractionStart");
    _ticker.stop();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    print("DEBUGG: _onInteractionEnd");
    _ticker.start();

    // final matrix = _controller.value;
    // final translation = matrix.getTranslation();

    // // スナップ先の位置を計算
    // final snappedX = (translation.x / _gridSize).round() * _gridSize;
    // final snappedY = (translation.y / _gridSize).round() * _gridSize;

    // // スナップ位置に移動
    // setState(() {
    //   _controller.value = Matrix4.identity()
    //     ..translate(snappedX, snappedY)
    //     ..scale(matrix.getMaxScaleOnAxis());
    // });
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    print("DEBUGG: _onInteractionUpdate");

    final matrix = _controller.value;
    final translation = matrix.getTranslation();

    // 現在の位置をグリッドサイズで割り、最も近いスナップ位置を計算
    final snappedX = (translation.x / _gridSize).round() * _gridSize;
    final snappedY = (translation.y / _gridSize).round() * _gridSize;
    final snappedPosition = Offset(snappedX, snappedY);

    print("DEBUGG: snappedPosition: $snappedPosition");

    // 前回のスナップ位置と異なる場合のみ更新
    if (snappedPosition != _lastSnappedPosition) {
      setState(() {
        _lastSnappedPosition = snappedPosition;
        // _controller.value = Matrix4.identity()
        //   ..translate(snappedX, snappedY)
        //   ..scale(matrix.getMaxScaleOnAxis());
      });

      // 触覚フィードバックを提供
      HapticFeedback.lightImpact();
    }
  }

  void _onTick(Duration elapsed) {
    _controller.value *= Matrix4.translationValues(
      0,
      (elapsed - _lastElapsed).inMilliseconds * -0.01,
      0,
    );
    _lastElapsed = elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      scaleEnabled: false, // 拡大・縮小を無効化
      panEnabled: true, // パン操作を有効化
      transformationController: _controller,
      onInteractionEnd: _onInteractionEnd,
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionStart: _onInteractionStart,
      child: widget.child,
    );
  }
}
