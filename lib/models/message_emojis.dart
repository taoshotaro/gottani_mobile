import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_emojis.freezed.dart';
part 'message_emojis.g.dart';

@freezed
class MessageEmojis with _$MessageEmojis {
  const factory MessageEmojis({
    // required String id,
    required String message_id,
    required String emoji,
    // required DateTime created_at,
  }) = _MessageEmojis;

  factory MessageEmojis.fromJson(Map<String, dynamic> json) =>
      _$MessageEmojisFromJson(json);
}
