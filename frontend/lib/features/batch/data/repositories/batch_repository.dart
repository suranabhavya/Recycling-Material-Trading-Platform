import 'package:dio/dio.dart';
import 'package:recycling_platform/features/batch/data/models/batch_model.dart';

class BatchRepository {
  final Dio _dio;

  BatchRepository(this._dio);

  Future<BatchModel> createBatch({
    required String name,
    String? description,
    required List<String> materialIds,
  }) async {
    try {
      final response = await _dio.post(
        '/batches',
        data: {
          'name': name,
          if (description != null) 'description': description,
          'materialIds': materialIds,
        },
      );

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create batch: $e');
    }
  }

  Future<List<BatchModel>> getAllBatches() async {
    try {
      final response = await _dio.get('/batches');

      final List<dynamic> data = response.data as List;
      return data.map((json) => BatchModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch batches: $e');
    }
  }

  Future<BatchModel> getBatchById(String id) async {
    try {
      final response = await _dio.get('/batches/$id');

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch batch: $e');
    }
  }

  Future<BatchModel> updateBatch({
    required String id,
    String? name,
    String? description,
    List<String>? materialIds,
  }) async {
    try {
      final response = await _dio.patch(
        '/batches/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (materialIds != null) 'materialIds': materialIds,
        },
      );

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update batch: $e');
    }
  }

  Future<void> deleteBatch(String id) async {
    try {
      await _dio.delete('/batches/$id');
    } catch (e) {
      throw Exception('Failed to delete batch: $e');
    }
  }

  Future<BatchModel> submitBatch(String id) async {
    try {
      final response = await _dio.post('/batches/$id/submit');

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit batch: $e');
    }
  }

  // Admin methods
  Future<List<BatchModel>> getPendingBatches() async {
    try {
      final response = await _dio.get('/batches/pending-admin-approval');

      final List<dynamic> data = response.data as List;
      return data.map((json) => BatchModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending batches: $e');
    }
  }

  Future<BatchModel> approveBatch(String id) async {
    try {
      final response = await _dio.post('/batches/$id/approve');

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to approve batch: $e');
    }
  }

  Future<BatchModel> rejectBatch(String id) async {
    try {
      final response = await _dio.post('/batches/$id/reject');

      return BatchModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to reject batch: $e');
    }
  }
}

