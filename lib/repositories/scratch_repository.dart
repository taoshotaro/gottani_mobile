import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/datasources/supabase_client.dart';
import 'package:gottani_mobile/models/scratch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    // 特に初期化の必要がない場合、空にしておきます。
  }

  Future<void> createScratch(int messageId, double dx, double dy, String emoji,
      double heatDelta) async {
    final response =
        await ref.read(supabaseClientProvider).from('Scratch').insert({
      'message_id': messageId,
      'dx': dx,
      'dy': dy,
      'emoji': emoji,
      'heat_delta': heatDelta,
      'created_at': DateTime.now().toIso8601String(),
    });
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
