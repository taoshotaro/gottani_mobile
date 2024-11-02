import 'package:freezed_annotation/freezed_annotation.dart';

part 'scratch.freezed.dart';
part 'scratch.g.dart';

@freezed
class Scratch with _$Scratch {
  const factory Scratch({
    required String id,
    required String message_id,
    required double x,
    required double y,
    required String emoji,
    required double heat_delta,
    required DateTime created_at,
    required String unique_id,
  }) = _Scratch;

  factory Scratch.fromJson(Map<String, dynamic> json) =>
      _$ScratchFromJson(json);
}
