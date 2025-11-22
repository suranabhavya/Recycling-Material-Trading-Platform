import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/scrap/data/models/material_model.dart';
import 'package:recycling_platform/features/scrap/data/repositories/material_repository.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MaterialRepository(dio);
});

final materialsProvider = FutureProvider<List<MaterialModel>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.getAllMaterials();
});

