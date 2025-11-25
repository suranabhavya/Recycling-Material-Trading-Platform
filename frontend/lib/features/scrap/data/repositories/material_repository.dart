import 'package:dio/dio.dart';
import 'package:recycling_platform/features/scrap/data/models/material_model.dart';

class MaterialRepository {
  final Dio _dio;

  MaterialRepository(this._dio);

  Future<MaterialModel> createMaterial(MaterialModel material) async {
    try {
      final response = await _dio.post(
        '/materials',
        data: material.toJson(),
      );

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create material: $e');
    }
  }

  Future<List<MaterialModel>> getAllMaterials() async {
    try {
      final response = await _dio.get('/materials');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch materials: $e');
    }
  }

  Future<MaterialModel> getMaterialById(String id) async {
    try {
      final response = await _dio.get('/materials/$id');

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch material: $e');
    }
  }

  Future<MaterialModel> updateMaterial(String id, MaterialModel material) async {
    try {
      final response = await _dio.patch(
        '/materials/$id',
        data: material.toJson(),
      );

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _dio.delete('/materials/$id');
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }

  // Approval methods
  Future<List<MaterialModel>> getPendingApprovals() async {
    try {
      final response = await _dio.get('/materials/pending-approvals');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending approvals: $e');
    }
  }

  Future<MaterialModel> approveMaterial(String materialId) async {
    try {
      final response = await _dio.post('/materials/$materialId/approve');

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve material: $e');
    }
  }

  Future<MaterialModel> rejectMaterial(String materialId, String reason) async {
    try {
      final response = await _dio.post(
        '/materials/$materialId/reject',
        data: {'reason': reason},
      );

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to reject material: $e');
    }
  }

  Future<List<MaterialModel>> getMyMaterials() async {
    try {
      final response = await _dio.get('/materials/my-materials');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch my materials: $e');
    }
  }

  Future<List<MaterialModel>> getInventory() async {
    try {
      final response = await _dio.get('/materials/inventory');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  Future<List<MaterialModel>> getApprovedMaterials() async {
    try {
      final response = await _dio.get('/materials/inventory');

      final List<dynamic> data = response.data as List;
      return data
          .map((json) => MaterialModel.fromJson(json))
          .where((material) => material.status == 'APPROVED')
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch approved materials: $e');
    }
  }

  Future<List<MaterialModel>> getPendingLeadApproval() async {
    try {
      final response = await _dio.get('/materials/pending-approvals');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending lead approvals: $e');
    }
  }

  Future<MaterialModel> leadApproveMaterial(String materialId) async {
    try {
      final response = await _dio.post('/materials/$materialId/approve');

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve material: $e');
    }
  }

  Future<MaterialModel> leadRejectMaterial(String materialId, String reason) async {
    try {
      final response = await _dio.post(
        '/materials/$materialId/reject',
        data: {'reason': reason},
      );

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to reject material: $e');
    }
  }
}

