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
}

