import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';
import 'package:recycling_platform/features/business/data/repositories/branches_repository.dart';

// Repository provider
final branchesRepositoryProvider = Provider<BranchesRepository>((ref) {
  return BranchesRepository(ref.watch(dioProvider));
});

// State class
class BranchesState {
  final List<BranchModel> branches;
  final bool isLoading;
  final String? error;

  BranchesState({
    this.branches = const [],
    this.isLoading = false,
    this.error,
  });

  BranchesState copyWith({
    List<BranchModel>? branches,
    bool? isLoading,
    String? error,
  }) {
    return BranchesState(
      branches: branches ?? this.branches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class BranchesNotifier extends StateNotifier<BranchesState> {
  final BranchesRepository _repository;

  BranchesNotifier(this._repository) : super(BranchesState());

  Future<void> fetchCompanyBranches(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final branches = await _repository.getCompanyBranches(companyId);
      state = BranchesState(branches: branches, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to load branches',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
    }
  }

  Future<void> createBranch({
    required String companyId,
    required String name,
    String? description,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    String? zipCode,
    String? phoneNumber,
    String? email,
    String? managerId,
    bool isHeadquarters = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newBranch = await _repository.createBranch(
        companyId: companyId,
        name: name,
        description: description,
        address: address,
        city: city,
        state: stateProvince,
        country: country,
        zipCode: zipCode,
        phoneNumber: phoneNumber,
        email: email,
        managerId: managerId,
        isHeadquarters: isHeadquarters,
      );

      final updatedBranches = [...state.branches, newBranch];
      state = BranchesState(branches: updatedBranches, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to create branch',
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
      rethrow;
    }
  }

  Future<void> updateBranch(String branchId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedBranch = await _repository.updateBranch(branchId, updates);

      final updatedBranches = state.branches.map((branch) {
        return branch.id == branchId ? updatedBranch : branch;
      }).toList();

      state = BranchesState(branches: updatedBranches, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to update branch',
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
      rethrow;
    }
  }

  Future<void> deleteBranch(String branchId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteBranch(branchId);

      final updatedBranches = state.branches.where((branch) => branch.id != branchId).toList();
      state = BranchesState(branches: updatedBranches, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to delete branch',
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
      rethrow;
    }
  }
}

// Provider
final branchesProvider = StateNotifierProvider<BranchesNotifier, BranchesState>((ref) {
  return BranchesNotifier(ref.watch(branchesRepositoryProvider));
});
