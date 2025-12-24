import 'package:dio/dio.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/business/data/models/user_detail_model.dart';

class BranchesRepository {
  final Dio _dio;

  BranchesRepository(this._dio);

  // Get all branches for company
  Future<List<BranchModel>> getCompanyBranches(String companyId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/branches/company/$companyId',
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => BranchModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Get single branch details
  Future<BranchModel> getBranchDetails(String branchId) async {
    final response = await _dio.get(
      '${AppConstants.baseUrl}/branches/$branchId',
    );

    return BranchModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Create new branch
  Future<BranchModel> createBranch({
    required String companyId,
    required String name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? phoneNumber,
    String? email,
    String? managerId,
    bool isHeadquarters = false,
  }) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/branches/company/$companyId',
      data: {
        'name': name,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
        'phoneNumber': phoneNumber,
        'email': email,
        'managerId': managerId,
        'isHeadquarters': isHeadquarters,
      },
    );

    return BranchModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Update branch
  Future<BranchModel> updateBranch(
    String branchId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.put(
      '${AppConstants.baseUrl}/branches/$branchId',
      data: updates,
    );

    return BranchModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Delete branch
  Future<void> deleteBranch(String branchId) async {
    await _dio.delete(
      '${AppConstants.baseUrl}/branches/$branchId',
    );
  }

  // Assign user to branch
  Future<void> assignUserToBranch(String userId, String branchId) async {
    await _dio.put(
      '${AppConstants.baseUrl}/branches/assign/$userId/$branchId',
    );
  }
}
