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

  // Lead-specific methods
  Future<List<MaterialModel>> getPendingLeadApproval() async {
    try {
      final response = await _dio.get('/materials/pending-lead-approval');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending materials: $e');
    }
  }

  Future<MaterialModel> leadApproveMaterial(String materialId) async {
    try {
      final response = await _dio.patch('/materials/$materialId/lead-approve');

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve material: $e');
    }
  }

  Future<MaterialModel> leadRejectMaterial(String materialId) async {
    try {
      final response = await _dio.patch('/materials/$materialId/lead-reject');

      return MaterialModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to reject material: $e');
    }
  }

  Future<List<MaterialModel>> getApprovedMaterials() async {
    try {
      final response = await _dio.get('/materials/approved-for-batching');

      final List<dynamic> data = response.data as List;
      return data.map((json) => MaterialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch approved materials: $e');
    }
  }
}

