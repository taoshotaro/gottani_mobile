import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod などアプリが動くための最小限の設定を行う Widget
@immutable
class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const providerOverrides = <Override>[];
    const providerObservers = <ProviderObserver>[];

    return ProviderScope(
      overrides: providerOverrides,
      observers: providerObservers,
      child: child,
    );
  }
}
