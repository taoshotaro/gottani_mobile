import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:gottani_mobile/screens/interactive/painter/grid_dots_painter.dart';

const _kScrollSpeed = 0.01;

class SnappingInteractiveViewer extends StatefulWidget {
  final List<Widget> children;
  final double gridSize;

  SnappingInteractiveViewer(
      {super.key, required this.children, this.gridSize = 46.0});

  @override
  _SnappingInteractiveViewerState createState() =>
      _SnappingInteractiveViewerState();
}

class _SnappingInteractiveViewerState extends State<SnappingInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late final TransformationController _controller;
  late final double _gridSize;
  double initialWidth = 0.0;
  Offset _lastSnappedPosition = Offset.zero;
  bool _interactive = false;

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _gridSize = widget.gridSize;
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        initialWidth = MediaQuery.of(context).size.width;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    _interactive = true;
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    _interactive = false;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final matrix = _controller.value;
    final translation = matrix.getTranslation();

    final snappedX = (translation.x / _gridSize).round() * _gridSize;
    final snappedY = (translation.y / _gridSize).round() * _gridSize;
    final snappedPosition = Offset(snappedX, snappedY);

    if (snappedPosition != _lastSnappedPosition) {
      setState(() {
        _lastSnappedPosition = snappedPosition;
      });

      HapticFeedback.lightImpact();
    }
  }

  void _onTick(Duration elapsed) {
    if (!_interactive) {
      _controller.value *= Matrix4.translationValues(
        0,
        (elapsed - _lastElapsed).inMilliseconds * -_kScrollSpeed,
        0,
      );
    }
    setState(() {
      _lastElapsed = elapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      scaleEnabled: false,
      panEnabled: true,
      transformationController: _controller,
      onInteractionEnd: _onInteractionEnd,
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionStart: _onInteractionStart,
      child: Container(
        width: initialWidth + 200,
        height: MediaQuery.of(context).size.height +
            (kIsWeb ? 2500 : 200) +
            _lastElapsed.inMilliseconds * _kScrollSpeed,
        color: Colors.black,
        child: CustomPaint(
          painter: GridDotsPainter(),
          child: Stack(children: widget.children),
        ),
      ),
    );
  }
}
