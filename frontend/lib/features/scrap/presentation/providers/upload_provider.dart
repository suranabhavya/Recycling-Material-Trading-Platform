import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/scrap/data/repositories/upload_repository.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UploadRepository(dio);
});

