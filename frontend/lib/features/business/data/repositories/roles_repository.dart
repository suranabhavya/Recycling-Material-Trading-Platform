import 'package:dio/dio.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';

class RolesRepository {
  final Dio _dio;

  RolesRepository(this._dio);

  // Get all roles for company
  Future<List<RoleModel>> getCompanyRoles(String companyId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/roles/company/$companyId',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => RoleModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Get single role details
  Future<RoleModel> getRoleDetails(String roleId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/roles/$roleId',
    );

    return RoleModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Create new role
  Future<RoleModel> createRole({
    required String companyId,
    required String name,
    String? description,
  }) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/roles/company/$companyId',
      data: {
        'name': name,
        'description': description,
      },
    );

    return RoleModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Update role
  Future<RoleModel> updateRole(
    String roleId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put(
      '${AppConstants.baseUrl}/roles/$roleId',
      data: updates,
    );

    return RoleModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Delete role
  Future<void> deleteRole(String roleId) async {
    await _dio.delete(
      '${AppConstants.baseUrl}/roles/$roleId',
    );
  }

  // Assign role to user
  Future<void> assignRoleToUser(String userId, String roleId) async {
    await _dio.put(
      '${AppConstants.baseUrl}/roles/assign/$userId/$roleId',
    );
  }
}
