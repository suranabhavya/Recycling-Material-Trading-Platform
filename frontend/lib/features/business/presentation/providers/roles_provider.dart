import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';
import 'package:recycling_platform/features/business/data/repositories/roles_repository.dart';

// Repository provider
final rolesRepositoryProvider = Provider<RolesRepository>((ref) {
  return RolesRepository(ref.watch(dioProvider));
});

// State class
class RolesState {
  final List<RoleModel> roles;
  final bool isLoading;
  final String? error;

  RolesState({
    this.roles = const [],
    this.isLoading = false,
    this.error,
  });

  RolesState copyWith({
    List<RoleModel>? roles,
    bool? isLoading,
    String? error,
  }) {
    return RolesState(
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier class
class RolesNotifier extends StateNotifier<RolesState> {
  final RolesRepository _repository;

  RolesNotifier(this._repository) : super(RolesState());

  Future<void> fetchCompanyRoles(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roles = await _repository.getCompanyRoles(companyId);
      state = RolesState(roles: roles, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to load roles',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
    }
  }

  Future<void> createRole({
    required String companyId,
    required String name,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRole = await _repository.createRole(
        companyId: companyId,
        name: name,
        description: description,
      );

      final updatedRoles = [...state.roles, newRole];
      state = RolesState(roles: updatedRoles, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to create role',
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

  Future<void> updateRole(String roleId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedRole = await _repository.updateRole(roleId, updates);

      final updatedRoles = state.roles.map((role) {
        return role.id == roleId ? updatedRole : role;
      }).toList();

      state = RolesState(roles: updatedRoles, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to update role',
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

  Future<void> deleteRole(String roleId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteRole(roleId);

      final updatedRoles = state.roles.where((role) => role.id != roleId).toList();
      state = RolesState(roles: updatedRoles, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to delete role',
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
final rolesProvider = StateNotifierProvider<RolesNotifier, RolesState>((ref) {
  return RolesNotifier(ref.watch(rolesRepositoryProvider));
});
