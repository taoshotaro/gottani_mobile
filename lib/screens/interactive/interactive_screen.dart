import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:gottani_mobile/repositories/message_emojis_repository.dart';
import 'package:gottani_mobile/repositories/message_repository.dart';
import 'package:gottani_mobile/screens/interactive/widgets/scribble_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/snapping_interactive_viewer.dart';
import 'package:gottani_mobile/screens/sample/icon_scroll_bar.dart';
import 'package:gottani_mobile/screens/sample/input_message_dialog.dart';

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
  double nextY = 100.0;

  @override
  void initState() {
    super.initState();
    viewerKey = GlobalKey();
    random = Random();

    unawaited(Future.microtask(() async {
      final messages = await ref.read(
        latestMessagesProvider(10).future,
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SnappingInteractiveViewer(
            key: viewerKey,
            children: messageWidgets,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IconScrollBar(
                onEmojiSelected: (emoji) {
                  ref.read(selectedEmojiProvider.notifier).state = emoji;
                },
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 0,
            child: SafeArea(
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                backgroundColor: Color(0xff1653F0),
                foregroundColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const InputMessageDialog();
                    },
                  );
                },
                child: Icon(Icons.add_rounded, size: 32),
              ),
            ),
          ),
        ],
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

    nextX += message.content.length * 15.0 + random.nextDouble() * 300.0;
    nextY += (0.25 + random.nextDouble() * 0.1) * _kVerticalInterval;
    if (nextX >= width * 0.9) {
      nextX = random.nextDouble() * 200.0;
      nextY += _kVerticalInterval * 0.75;
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
