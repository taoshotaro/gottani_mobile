import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/screens/sample/icon_scroll_bar.dart';
import 'package:gottani_mobile/screens/sample/input_message_dialog.dart';

@immutable
@RoutePage()
class SampleScreen extends ConsumerWidget {
  const SampleScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
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
            SizedBox(
              width: 0.0,
              height: 20.0,
            ),
            IconScrollBar(),
          ],
        ),
      ),
    );
  }
}
