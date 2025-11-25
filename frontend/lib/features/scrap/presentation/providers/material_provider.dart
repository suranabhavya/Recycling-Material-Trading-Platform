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

final pendingApprovalsProvider = FutureProvider<List<MaterialModel>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.getPendingApprovals();
});

final myMaterialsProvider = FutureProvider<List<MaterialModel>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.getMyMaterials();
});

final inventoryProvider = FutureProvider<List<MaterialModel>>((ref) async {
  final repository = ref.watch(materialRepositoryProvider);
  return repository.getInventory();
});

class MaterialState {
  final bool isLoading;
  final String? error;

  MaterialState({
    this.isLoading = false,
    this.error,
  });

  MaterialState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return MaterialState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MaterialNotifier extends StateNotifier<MaterialState> {
  final MaterialRepository _repository;

  MaterialNotifier(this._repository) : super(MaterialState());

  Future<void> approveMaterial(String materialId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.approveMaterial(materialId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> rejectMaterial(String materialId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.rejectMaterial(materialId, reason);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final materialNotifierProvider = StateNotifierProvider<MaterialNotifier, MaterialState>((ref) {
  final repository = ref.watch(materialRepositoryProvider);
  return MaterialNotifier(repository);
});

