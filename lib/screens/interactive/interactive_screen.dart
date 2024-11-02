import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/screens/interactive/painter/grid_dots_painter.dart';
import 'package:gottani_mobile/screens/interactive/widgets/comment_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/scribble_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/snapping_interactive_viewer.dart';

@immutable
@RoutePage()
class InteractiveScreen extends HookWidget {
  const InteractiveScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final globalKey = useMemoized(() => GlobalKey());

    return Scaffold(
      body: SnappingInteractiveViewer(
        key: globalKey,
        child: Container(
          width: 2000,
          height: 2000,
          color: Colors.black,
          child: CustomPaint(
            painter: GridDotsPainter(),
            child: Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 50,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 500,
                  top: 100,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 900,
                  top: 100,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 1500,
                  top: 150,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 100,
                  top: 350,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 500,
                  top: 400,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 900,
                  top: 400,
                  child: ScribbleWidget(),
                ),
                Positioned(
                  left: 1500,
                  top: 450,
                  child: ScribbleWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
