import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gottani_mobile/repositories/sample_summary_repository.dart';

@immutable
@RoutePage()
class SampleScreen extends ConsumerWidget {
  const SampleScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(sampleSummaryPageRepositoryProvider(page: 0));
    return Scaffold(
      body: summary.when(
        data: (summary) => Text(summary[0].name),
        error: (err, stack) => Text('Error'),
        loading: () => const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
