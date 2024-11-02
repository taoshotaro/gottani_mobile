import 'package:freezed_annotation/freezed_annotation.dart';

part 'scratch.freezed.dart';
part 'scratch.g.dart';

@freezed
class Scratch with _$Scratch {
  const factory Scratch({
    required String id,
    required String messageId,
    required double x,
    required double y,
    required String emoji,
    required double heatDelta,
    required DateTime createdAt,
  }) = _Scratch;

  factory Scratch.fromJson(Map<String, dynamic> json) =>
      _$ScratchFromJson(json);
}
