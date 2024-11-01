import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gottani_mobile/app/app.dart';
import 'package:gottani_mobile/app/scope.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) => {};
  }

  runApp(
    const AppScope(child: App()),
  );
}
