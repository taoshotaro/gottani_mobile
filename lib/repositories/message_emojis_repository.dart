import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/message_emojis.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'message_emojis_repository.g.dart';

final selectedEmojiProvider = StateProvider<String>((ref) => '🔥');

@riverpod
Stream<List<MessageEmojis>> messageEmojisStream(Ref ref, String messageId) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase
      .from('message_emojis')
      .stream(primaryKey: ['id'])
      .eq('message_id', messageId)
      .order('created_at')
      .map((maps) => maps.map((map) => MessageEmojis.fromJson(map)).toList());
}

// @riverpod
// Future<List<MessageEmojis>> getMessageEmojis(Ref ref, String messageId) async {
//   final supabase = ref.watch(supabaseClientProvider);

//   final response = await supabase
//       .from('message_emojis')
//       .select()
//       .eq('message_id', messageId)
//       .order('created_at');

//   return response.map((json) => MessageEmojis.fromJson(json)).toList();
// }

@riverpod
MessageEmojisRepository messageEmojisRepository(Ref ref) =>
    MessageEmojisRepository(
      supabase: ref.watch(supabaseClientProvider),
    );

class MessageEmojisRepository {
  const MessageEmojisRepository({
    required this.supabase,
  });

  final SupabaseClient supabase;

  /// メッセージの送信
  Future<void> send(String messageId, String emoji) async {
    await supabase.from('message_emojis').insert({
      'message_id': messageId,
      'emoji': emoji,
    });
  }
}
