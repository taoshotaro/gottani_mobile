import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

extension RiverpodRefExt on Ref {
  /// 指定した [ChangeNotifier] や [ValueNotifier] などをこの参照に紐付けます。
  /// これにより、[ChangeNotifier] 側で変更があった際に Riverpod にも変更が通知されます。
  void bindChangeNotifier<T extends ChangeNotifier>(T notifier) {
    onDispose(notifier.dispose);
    notifier.addListener(notifyListeners);
  }

  /// 指定した [Provider] がすでに [ValueNotifier] の初期化を済ませて保持していた場合は
  /// 保持している [ValueNotifier] に対して値を設定します。
  void notifyValueIfExists<T>(
    ProviderBase<ValueNotifier<T>> notifier,
    T value,
  ) {
    if (exists(notifier)) {
      read(notifier).value = value;
    }
  }

  /// 指定した時間だけ、必ず値を保持し続けるように設定します。
  void cacheFor(Duration duration) {
    final link = keepAlive();
    Timer(duration, link.close);
  }

  /// 参照が外れた場合でも、指定した時間だけ値を保持し続けるように設定します。
  void keepResonance(Duration duration) {
    final link = keepAlive();
    Timer? timer;

    onCancel(() {
      timer?.cancel();
      timer = Timer(duration, link.close);
    });
    onResume(() {
      timer?.cancel();
      timer = null;
    });
    onDispose(() {
      timer?.cancel();
      timer = null;
    });
  }
}
