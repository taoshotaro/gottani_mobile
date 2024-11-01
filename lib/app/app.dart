import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gottani_mobile/screens/router.dart';

/// ルーティング設定をインスタンス化する Widget
@immutable
class App extends HookWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final router = useMemoized(() => AppRouter());
    return MaterialApp.router(
      title: 'Gottani',
      routerConfig: router.config(),
    );
  }
}
