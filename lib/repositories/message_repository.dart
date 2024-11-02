import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    supabase = ref.watch(supabaseClientProvider);
  }

  late final SupabaseClient supabase;

  Future<void> createMessage(String content) async {
    final response = await supabase.from('Message').insert({
      'content': content,
      'heat': 0,
    });
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
