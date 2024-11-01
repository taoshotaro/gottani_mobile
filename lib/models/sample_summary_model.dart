import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_summary_model.freezed.dart';

@immutable
@freezed
class SampleSummaryModel with _$SampleSummaryModel {
  const factory SampleSummaryModel({
    required int id,
    required String name,
  }) = _SampleSummaryModel;
}
