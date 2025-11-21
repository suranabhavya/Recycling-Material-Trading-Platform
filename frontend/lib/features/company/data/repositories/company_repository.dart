import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/company/data/models/company_model.dart';

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
}

