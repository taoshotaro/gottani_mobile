import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_model.freezed.dart';

@immutable
@freezed
class SampleModel with _$SampleModel {
  const factory SampleModel({
    required int id,
    required String name,
    required String description,
  }) = _SampleModel;
}
