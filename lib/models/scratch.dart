import 'package:freezed_annotation/freezed_annotation.dart';

part 'scratch.freezed.dart';
part 'scratch.g.dart';

@freezed
class Scratch with _$Scratch {
  const factory Scratch({
    required int id,
    required int messageId,
    required double dx,
    required double dy,
    required String emoji,
    required double heatDelta,
    required DateTime createdAt,
  }) = _Scratch;

  factory Scratch.fromJson(Map<String, dynamic> json) =>
      _$ScratchFromJson(json);
}
