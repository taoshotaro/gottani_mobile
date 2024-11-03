import 'package:flutter/material.dart';

class WhiteoutDialog extends StatelessWidget {
  const WhiteoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Text(''),
      ),
    );
  }
}
