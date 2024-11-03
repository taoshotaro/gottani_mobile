import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/scratch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'scratch_repository.g.dart';

class AppUuid {
  static final uuid = Uuid().v1();
}

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
            final scratch = Scratch.fromJson(payload.newRecord);
            if (scratch.unique_id != AppUuid.uuid) {
              streamController.add(scratch);
            }
          })
      .subscribe();

  ref.onDispose(() {
    unawaited(subscription.unsubscribe());
    unawaited(streamController.close());
  });

  return streamController.stream;
}

@riverpod
ScratchRepository scrachRepository(Ref ref) => ScratchRepository(
      supabase: ref.watch(supabaseClientProvider),
    );

class ScratchRepository {
  const ScratchRepository({
    required this.supabase,
  });

  final SupabaseClient supabase;

  Future<void> createScratch(
    String messageId,
    double x,
    double y,
    String emoji,
    double heatDelta,
    int type,
  ) async {
    final response = await supabase.from('scratch').insert({
      'message_id': messageId,
      'x': x,
      'y': y,
      'emoji': emoji,
      'heat_delta': heatDelta,
      'created_at': DateTime.now().toIso8601String(),
      'unique_id': AppUuid.uuid,
      'type': type,
    });
  }
}
