import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'message_repository.g.dart';

@riverpod
Stream<Message> newMessageStream(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
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
Future<List<Message>> latestMessages(Ref ref, int count) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('message').select().limit(count);
  return response.map((json) => Message.fromJson(json)).toList();
}

@riverpod
MessageRepository messageRepository(Ref ref) => MessageRepository(
      supabase: ref.watch(supabaseClientProvider),
    );

class MessageRepository {
  const MessageRepository({
    required this.supabase,
  });

  final SupabaseClient supabase;

  /// メッセージの送信
  Future<void> send(String content) async {
    await supabase.from('message').insert({
      'content': content,
      'heat': 0,
    });
  }
}
