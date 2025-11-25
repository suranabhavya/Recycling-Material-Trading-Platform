import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/company/data/models/company_model.dart';
import 'package:recycling_platform/features/company/data/models/company_hierarchy_model.dart';

class CompanyRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  CompanyRepository(this._dio, this._storage);

  Future<List<CompanyModel>> getAllCompanies() async {
    final response = await _dio.get('${AppConstants.baseUrl}/companies');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => CompanyModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CompanyModel> createCompany({
    required String name,
    required String email,
    String? phone,
    String? address,
    required String type,
    required String hierarchyMode,
    required List<Map<String, dynamic>> roleTemplates,
    List<Map<String, dynamic>>? orgUnits,
  }) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.post(
      '${AppConstants.baseUrl}/companies',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'type': type,
        'hierarchyMode': hierarchyMode,
        'roleTemplates': roleTemplates,
        if (orgUnits != null) 'orgUnits': orgUnits,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return CompanyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> joinCompany(String companyId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.post(
      '${AppConstants.baseUrl}/companies/join',
      data: {'companyId': companyId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPendingApprovals(String companyId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.get(
      '${AppConstants.baseUrl}/companies/$companyId/pending-approvals',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> approveUser(String userId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.post(
      '${AppConstants.baseUrl}/companies/approve/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rejectUser(String userId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.post(
      '${AppConstants.baseUrl}/companies/reject/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCompanyMembers(String companyId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.get(
      '${AppConstants.baseUrl}/companies/$companyId/members',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  Future<Map<String, dynamic>> updateUserRole(String userId, String role) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.patch(
      '${AppConstants.baseUrl}/companies/update-role/$userId',
      data: {'role': role},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> kickMember(String userId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.post(
      '${AppConstants.baseUrl}/companies/kick/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  // Hierarchy Management Methods
  Future<CompanyHierarchyModel> getCompanyHierarchy(String companyId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.get(
      '${AppConstants.baseUrl}/companies/$companyId/hierarchy',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return CompanyHierarchyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> assignMemberToLead({
    required String memberId,
    required String leadId,
  }) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.patch(
      '${AppConstants.baseUrl}/companies/assign-lead',
      data: {
        'memberId': memberId,
        'leadId': leadId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> unassignMemberFromLead(String memberId) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.patch(
      '${AppConstants.baseUrl}/companies/unassign-lead/$memberId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }
}

