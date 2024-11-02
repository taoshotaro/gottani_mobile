import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'message_repository.g.dart';

@riverpod
Stream<Message> newMessageStream(Ref ref) {
  final supabase = ref.read(supabaseClientProvider);

  final streamController = StreamController<Message>();

  final subscription = supabase
      .channel('public:message')
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'message',
          callback: (payload) {
            streamController.add(Message.fromJson(payload.newRecord));
          })
      .subscribe();

  ref.onDispose(() {
    unawaited(subscription.unsubscribe());
    unawaited(streamController.close());
  });

  return streamController.stream;
}

@riverpod
class MessageRepository extends _$MessageRepository {
  @override
  Future<void> build() async {
    supabase = ref.watch(supabaseClientProvider);
  }

  late final SupabaseClient supabase;

  Future<List<Message>> fetchMessages(int count) async {
    final response = await supabase.from('Message').select().limit(count);

    return response.map((json) => Message.fromJson(json)).toList();
  }

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
