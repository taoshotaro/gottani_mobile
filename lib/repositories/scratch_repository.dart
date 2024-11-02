import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/scratch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'scratch_repository.g.dart';

@riverpod
Stream<Scratch> scratchStream(Ref ref, String messageId) {
  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('scratch')
      .stream(primaryKey: ['id'])
      .eq('message_id', messageId)
      .order('created_at', ascending: false)
      .limit(1)
      .map((data) => data.isNotEmpty ? Scratch.fromJson(data.first) : null)
      .where((scratch) => scratch != null)
      .cast<Scratch>();
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
