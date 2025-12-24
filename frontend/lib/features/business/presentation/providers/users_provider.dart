import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';
import 'package:recycling_platform/features/business/data/repositories/users_repository.dart';

// Repository provider
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(dioProvider));
});

// State class
class UsersState {
  final List<UserDetailModel> users;
  final bool isLoading;
  final String? error;
  final Map<String, List<UserDetailModel>> usersByBranch;

  UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.usersByBranch = const {},
  });

  UsersState copyWith({
    List<UserDetailModel>? users,
    bool? isLoading,
    String? error,
    Map<String, List<UserDetailModel>>? usersByBranch,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      usersByBranch: usersByBranch ?? this.usersByBranch,
    );
  }

  // Group users by branch
  Map<String, List<UserDetailModel>> get groupedByBranch {
    if (usersByBranch.isNotEmpty) return usersByBranch;

    final Map<String, List<UserDetailModel>> grouped = {};
    for (final user in users) {
      final branchName = user.branch?.name ?? 'Unassigned';
      if (!grouped.containsKey(branchName)) {
        grouped[branchName] = [];
      }
      grouped[branchName]!.add(user);
    }
    return grouped;
  }
}

// Notifier class
class UsersNotifier extends StateNotifier<UsersState> {
  final UsersRepository _repository;

  UsersNotifier(this._repository) : super(UsersState());

  Future<void> fetchCompanyUsers(String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _repository.getCompanyUsers(companyId);
      state = UsersState(users: users, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to load users',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred',
      );
    }
  }

  Future<void> inviteUser({
    required String email,
    required String name,
    required String branchId,
    String? roleId,
    String? directManagerId,
    String userType = 'USER',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.inviteUser(
        email: email,
        name: name,
        branchId: branchId,
        roleId: roleId,
        directManagerId: directManagerId,
        userType: userType,
      );
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to invite user',
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

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _repository.updateUser(userId, updates);

      // Update user in list
      final updatedUsers = state.users.map((user) {
        return user.id == userId ? updatedUser : user;
      }).toList();

      state = UsersState(users: updatedUsers, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to update user',
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

  Future<void> assignDirectManager(String userId, String? managerId) async {
    try {
      await _repository.assignDirectManager(userId, managerId);

      // Refresh user in list
      final updatedUsers = [...state.users];
      final userIndex = updatedUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        // In real app, fetch updated user details
        // For now, just update the manager ID
      }

      state = state.copyWith(users: updatedUsers);
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? 'Failed to assign manager',
      );
      rethrow;
    }
  }

  Future<void> assignBranch(String userId, String branchId) async {
    try {
      await _repository.assignBranch(userId, branchId);
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? 'Failed to assign branch',
      );
      rethrow;
    }
  }

  Future<void> assignRole(String userId, String? roleId) async {
    try {
      await _repository.assignRole(userId, roleId);
    } on DioException catch (e) {
      state = state.copyWith(
        error: e.response?.data['message'] ?? 'Failed to assign role',
      );
      rethrow;
    }
  }

  Future<void> removeUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.removeUser(userId);

      final updatedUsers = state.users.where((user) => user.id != userId).toList();
      state = UsersState(users: updatedUsers, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to remove user',
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
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref.watch(usersRepositoryProvider));
});
