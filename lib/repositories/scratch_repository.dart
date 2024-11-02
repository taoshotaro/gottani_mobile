import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/scratch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'scratch_repository.g.dart';

@riverpod
Stream<Scratch> scratchStreamByMessageId(Ref ref, String messageId) {
  final supabase = ref.watch(supabaseClientProvider);

  final streamController = StreamController<Scratch>();

  final subscription = supabase
      .channel('public:scratch:message_id=$messageId')
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'scratch',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'message_id',
            value: messageId,
          ),
          callback: (payload) {
            streamController.add(Scratch.fromJson(payload.newRecord));
          })
      .subscribe();

  ref.onDispose(() {
    unawaited(subscription.unsubscribe());
    unawaited(streamController.close());
  });

  return streamController.stream;
}

@riverpod
class ScratchRepository extends _$ScratchRepository {
  @override
  Future<void> build() async {
    supabase = ref.watch(supabaseClientProvider);
  }

  late final SupabaseClient supabase;

  Future<void> createScratch(String messageId, double x, double y, String emoji,
      double heatDelta) async {
    final response = await supabase.from('scratch').insert({
      'message_id': messageId,
      'x': x,
      'y': y,
      'emoji': emoji,
      'heat_delta': heatDelta,
      'created_at': DateTime.now().toIso8601String(),
    });
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
