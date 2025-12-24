import 'package:dio/dio.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';

class UsersRepository {
  final Dio _dio;

  UsersRepository(this._dio);

  // Get all users in company
  Future<List<UserDetailModel>> getCompanyUsers(String companyId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/users/company/$companyId',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => UserDetailModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Get users by branch
  Future<List<UserDetailModel>> getUsersByBranch(String branchId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/users/branch/$branchId',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => UserDetailModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Get single user details
  Future<UserDetailModel> getUserDetails(String userId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/users/$userId',
    );

    return UserDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Invite user to company
  Future<void> inviteUser({
    required String email,
    required String name,
    required String branchId,
    String? roleId,
    String? directManagerId,
    String userType = 'USER',
  }) async {
    await _dio.post(
      '${AppConstants.baseUrl}/users/invite',
      data: {
        'email': email,
        'name': name,
        'branchId': branchId,
        'roleId': roleId,
        'directManagerId': directManagerId,
        'userType': userType,
      },
    );
  }

  // Update user details
  Future<UserDetailModel> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put(
      '${AppConstants.baseUrl}/users/$userId',
      data: updates,
    );

    return UserDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Assign direct manager
  Future<void> assignDirectManager(String userId, String? managerId) async {
    await _dio.put(
      '${AppConstants.baseUrl}/users/$userId/manager',
      data: {'directManagerId': managerId},
    );
  }

  // Assign to branch
  Future<void> assignBranch(String userId, String branchId) async {
    await _dio.put(
      '${AppConstants.baseUrl}/users/$userId/branch',
      data: {'branchId': branchId},
    );
  }

  // Assign role
  Future<void> assignRole(String userId, String? roleId) async {
    await _dio.put(
      '${AppConstants.baseUrl}/users/$userId/role',
      data: {'roleId': roleId},
    );
  }

  // Remove user
  Future<void> removeUser(String userId) async {
    await _dio.delete(
      '${AppConstants.baseUrl}/users/$userId',
    );
  }
}
