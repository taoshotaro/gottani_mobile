import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gottani_mobile/extensions/riverpod.dart';
import 'package:gottani_mobile/models/sample_model.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_repository.g.dart';

const _kPageSize = 30;

/// サンプルデータのリポジトリ
@riverpod
class SampleRepository extends _$SampleRepository {
  @override
  Future<SampleModel> build(int sampleId) async {
    return SampleModel(
      id: sampleId,
      name: 'Sample Name',
      description: 'Sample Description',
    );
  }

  /// 更新をかける
  Future<void> post(SampleModel sample) async {
    assert(sample.id != sampleId);

    // キャッシュの更新
    state = AsyncValue.data(sample);

    // キャッシュを破棄する場合
    // ref.invalidateSelf();

    // 更新通知
    ref.notifyValueIfExists(
      sampleIndirectNotifierProvider(sampleId),
      sample,
    );
  }
}

/// サンプルデータの更新を間接的に通知するための [ValueNotifier]
@riverpod
ValueNotifier<SampleModel?> sampleIndirectNotifier(
  Ref ref,
  int sampleId,
) {
  final notifier = ValueNotifier<SampleModel?>(null);
  ref.onDispose(notifier.dispose);
  return notifier;
}
