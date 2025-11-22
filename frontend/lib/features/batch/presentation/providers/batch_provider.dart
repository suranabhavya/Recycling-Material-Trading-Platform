import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/batch/data/repositories/batch_repository.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BatchRepository(dio);
});

