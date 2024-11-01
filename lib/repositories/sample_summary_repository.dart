import 'package:gottani_mobile/models/sample_model.dart';
import 'package:gottani_mobile/models/sample_summary_model.dart';
import 'package:gottani_mobile/repositories/sample_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sample_summary_repository.g.dart';

const _kPageSize = 30;

@riverpod
class SampleSummaryPageRepository extends _$SampleSummaryPageRepository {
  @override
  Future<List<SampleSummaryModel>> build({
    required int page,
    String? query,
  }) async {
    final summaries = List.generate(_kPageSize, (index) {
      final sampleId = page * _kPageSize + index;

      final notifier = ref.watch(sampleIndirectNotifierProvider(sampleId));
      notifier.addListener(() => _updateAt(index, notifier.value));

      return SampleSummaryModel(id: sampleId, name: 'Sample: id=$sampleId');
    });
    return summaries;
  }

  void _updateAt(int index, SampleModel? value) {
    if (value == null) {
      return;
    }

    final stateValue = state.value;
    if (stateValue == null) {
      return;
    }

    final newStateItem = SampleSummaryModel(
      id: value.id,
      name: value.name,
    );
    if (newStateItem == stateValue[index]) {
      return;
    }

    stateValue[index] = newStateItem;
    ref.notifyListeners();
  }
}
