import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:gottani_mobile/repositories/message_repository.dart';
import 'package:gottani_mobile/screens/interactive/widgets/scribble_widget.dart';
import 'package:gottani_mobile/screens/interactive/widgets/snapping_interactive_viewer.dart';
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
  late final Key viewerKey;
  late final Random random;
  final List<Widget> messageWidgets = [];

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
      resizeToAvoidBottomInset: false,
      body: SnappingInteractiveViewer(
        key: viewerKey,
        children: messageWidgets,
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const InputMessageDialog();
            },
          );
        },
        child: Text('Show Dialog'),
      ),
    );
  }

  void _pushMessage(Message message) {
    messageWidgets.add(
      _PositionedScribbleWidget(
        key: ValueKey(message.id),
        left: random.nextDouble() * MediaQuery.of(context).size.width * 0.5,
        top: (messageWidgets.length + 1) * _kVerticalInterval +
            random.nextDouble() * _kVerticalInterval * 0.25,
        message: message,
      ),
    );
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
