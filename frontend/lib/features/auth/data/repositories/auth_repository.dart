import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/auth/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/auth/login',
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _storage.write(key: AppConstants.accessTokenKey, value: authResponse.token);
    return authResponse;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? companyId,
  }) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        if (companyId != null) 'companyId': companyId,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _storage.write(key: AppConstants.accessTokenKey, value: authResponse.token);
    return authResponse;
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }
}

