import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/scratch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'scratch_repository.g.dart';

@riverpod
Stream<List<Scratch>> scratchStream(Ref ref, int messageId) {
  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('Scratch')
      .stream(primaryKey: ['id'])
      .eq('message_id', messageId)
      .map((data) => data.map((json) => Scratch.fromJson(json)).toList());
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
    final response = await supabase.from('Scratch').insert({
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
