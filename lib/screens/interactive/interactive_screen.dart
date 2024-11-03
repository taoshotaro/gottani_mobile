import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:gottani_mobile/repositories/message_repository.dart';
import 'package:gottani_mobile/screens/interactive/widgets/scribble_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/snapping_interactive_viewer.dart';

const _kVerticalInterval = 100.0;

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
  late final GlobalKey viewerKey;
  late final Random random;
  final List<Widget> messageWidgets = [];
  double nextX = 0.0;
  double nextY = 0.0;

  @override
  void initState() {
    super.initState();
    viewerKey = GlobalKey();
    random = Random();

    unawaited(Future.microtask(() async {
      final messages = await ref.read(
        latestMessagesProvider(5).future,
      );
      if (!context.mounted) {
        return;
      }

      messages.forEach(_pushMessage);
      setState(() {});
    }));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newMessageStreamProvider.future, (_, message) {
      message.then((message) {
        if (!context.mounted) {
          return;
        }
        _pushMessage(message);
        setState(() {});
      });
    });

    return Scaffold(
      body: SnappingInteractiveViewer(
        key: viewerKey,
        children: messageWidgets,
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

  void _pushMessage(Message message) {
    messageWidgets.add(
      _PositionedScribbleWidget(
        key: ValueKey(message.id),
        left: nextX,
        top: nextY,
        message: message,
      ),
    );

    final renderBox =
        viewerKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? MediaQuery.of(context).size.width;

    nextX += message.content.length * 12.0 + random.nextDouble() * 200.0;
    nextY += _kVerticalInterval * 0.1 * random.nextDouble() * 0.1;
    if (nextX >= width * 0.9) {
      nextX = random.nextDouble() * 200.0;
      nextY += _kVerticalInterval;
    }
  }
}

@immutable
class _PositionedScribbleWidget extends StatelessWidget {
  const _PositionedScribbleWidget({
    super.key,
    required this.message,
    required this.left,
    required this.top,
  });

  final Message message;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: ScribbleWidget(
        id: message.id,
        content: message.content,
        initialHeat: message.heat,
      ),
    );
  }
}
