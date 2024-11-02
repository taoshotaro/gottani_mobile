import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:gottani_mobile/repositories/message_repository.dart';
import 'package:gottani_mobile/screens/interactive/painter/grid_dots_painter.dart';
import 'package:gottani_mobile/screens/interactive/widgets/scribble_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/snapping_interactive_viewer.dart';

@immutable
@RoutePage()
class InteractiveScreen extends ConsumerStatefulWidget {
  const InteractiveScreen({
    super.key,
  });

  @override
  ConsumerState<InteractiveScreen> createState() => InteractiveScreenState();
}

class InteractiveScreenState extends ConsumerState<InteractiveScreen> {
  late final Key viewerKey;
  final List<Widget> messageWidgets = [];

  @override
  void initState() {
    super.initState();
    viewerKey = GlobalKey();

    unawaited(Future.microtask(() async {
      final messages = await ref.read(
        latestMessagesProvider(20).future,
      );
      if (!context.mounted) {
        return;
      }

      messageWidgets.addAll(messages.map(
        (message) => _PositionedScribbleWidget(
          key: ValueKey(message.id),
          message: message,
        ),
      ));
      setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newMessageStreamProvider.future, (_, message) {
      message.then((message) {
        if (context.mounted) {
          return;
        }
        messageWidgets.add(
          _PositionedScribbleWidget(
            key: ValueKey(message.id),
            message: message,
          ),
        );
        setState(() {});
      });
    });

    return Scaffold(
      body: SnappingInteractiveViewer(
        key: viewerKey,
        child: Container(
          width: 2000,
          height: 2000,
          color: Colors.black,
          child: CustomPaint(
            painter: GridDotsPainter(),
            child: Stack(children: messageWidgets),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(children: [
          TextButton(
            onPressed: () => ref
                .read(messageRepositoryProvider)
                .send('added: ${DateTime.now().toIso8601String()}'),
            child: const Text('add'),
          )
        ]),
      ),
    );
  }
}

@immutable
class _PositionedScribbleWidget extends StatelessWidget {
  const _PositionedScribbleWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: ScribbleWidget(
        id: message.id,
        content: message.content,
        initialHeat: message.heat,
      ),
    );
  }
}
