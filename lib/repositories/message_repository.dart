import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_repository.g.dart';

@riverpod
Stream<List<Message>> messageStream(Ref ref) {
  final supabase = ref.read(supabaseClientProvider);

  return supabase.from('Message').stream(primaryKey: ['id']).map(
      (data) => data.map((json) => Message.fromJson(json)).toList());
}

@riverpod
class MessageRepository extends _$MessageRepository {
  @override
  Future<void> build() async {
    // 特に初期化の必要がない場合、空にしておきます。
  }

  Future<void> createMessage(String content) async {
    final response = await ref
        .read(supabaseClientProvider)
        .from('Message')
        .insert({'content': content, 'heat': 0});
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
