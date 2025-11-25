import 'package:dio/dio.dart';
import '../models/role_template_model.dart';
import '../models/organizational_unit_model.dart';

class HierarchyRepository {
  final Dio _dio;

  HierarchyRepository(this._dio);

  // Role Template APIs
  Future<RoleTemplateModel> createRoleTemplate(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/hierarchy/role-templates', data: data);
      return RoleTemplateModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create role template: $e');
    }
  }

  Future<List<RoleTemplateModel>> getRoleTemplates(String companyId) async {
    try {
      final response = await _dio.get('/hierarchy/role-templates', queryParameters: {'companyId': companyId});
      return (response.data as List)
          .map((e) => RoleTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get role templates: $e');
    }
  }

  Future<RoleTemplateModel> getRoleTemplate(String id) async {
    try {
      final response = await _dio.get('/hierarchy/role-templates/$id');
      return RoleTemplateModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get role template: $e');
    }
  }

  Future<RoleTemplateModel> updateRoleTemplate(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/hierarchy/role-templates/$id', data: data);
      return RoleTemplateModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update role template: $e');
    }
  }

  Future<void> deleteRoleTemplate(String id) async {
    try {
      await _dio.delete('/hierarchy/role-templates/$id');
    } catch (e) {
      throw Exception('Failed to delete role template: $e');
    }
  }

  // Organizational Unit APIs
  Future<OrganizationalUnitModel> createOrgUnit(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/hierarchy/org-units', data: data);
      return OrganizationalUnitModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create organizational unit: $e');
    }
  }

  Future<List<OrganizationalUnitModel>> getOrgUnits(String companyId) async {
    try {
      final response = await _dio.get('/hierarchy/org-units', queryParameters: {'companyId': companyId});
      return (response.data as List)
          .map((e) => OrganizationalUnitModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get organizational units: $e');
    }
  }

  Future<List<OrganizationalUnitModel>> getOrgTree(String companyId) async {
    try {
      final response = await _dio.get('/hierarchy/org-units/tree', queryParameters: {'companyId': companyId});
      return (response.data as List)
          .map((e) => OrganizationalUnitModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get organizational tree: $e');
    }
  }

  Future<OrganizationalUnitModel> getOrgUnit(String id) async {
    try {
      final response = await _dio.get('/hierarchy/org-units/$id');
      return OrganizationalUnitModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get organizational unit: $e');
    }
  }

  Future<OrganizationalUnitModel> updateOrgUnit(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/hierarchy/org-units/$id', data: data);
      return OrganizationalUnitModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update organizational unit: $e');
    }
  }

  Future<void> deleteOrgUnit(String id) async {
    try {
      await _dio.delete('/hierarchy/org-units/$id');
    } catch (e) {
      throw Exception('Failed to delete organizational unit: $e');
    }
  }

  // Approval Chain API
  Future<List<int>> getApprovalChainLevels() async {
    try {
      final response = await _dio.get('/hierarchy/approval-chain');
      return List<int>.from(response.data as List);
    } catch (e) {
      throw Exception('Failed to get approval chain: $e');
    }
  }
}
