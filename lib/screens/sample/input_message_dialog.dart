import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InputMessageDialog extends HookWidget {
  const InputMessageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final messageText = useState('');

    return AlertDialog(
      contentPadding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.0,
                    vertical: 8.0,
                  ),
                  minimumSize: Size(0.0, 0.0),
                ),
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          // Middle section with a centered TextField
          TextField(
            maxLines: null,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22.0,
            ),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'なにを考えてる？',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              messageText.value = value;
            },
          ),
          // Bottom section with a button on the bottom-right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/send.png',
                  width: 30.0,
                  height: 30.0,
                ),
                onPressed: () {
                  // Add your send action here
                },
                style: IconButton.styleFrom(
                  backgroundColor:
                      messageText.value.isEmpty ? Colors.grey : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
