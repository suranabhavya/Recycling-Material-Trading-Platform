import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';
import 'package:recycling_platform/features/auth/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '${AppConstants.baseUrl}/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _storage.write(key: AppConstants.accessTokenKey, value: authResponse.token);
    return authResponse;
  }

  Future<void> resendOtp(String email) async {
    await _dio.post(
      '${AppConstants.baseUrl}/auth/resend-otp',
      data: {'email': email},
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '${AppConstants.baseUrl}/auth/login',
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _storage.write(key: AppConstants.accessTokenKey, value: authResponse.token);
    return authResponse;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      '${AppConstants.baseUrl}/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    await _dio.post(
      '${AppConstants.baseUrl}/auth/reset-password',
      data: {'email': email, 'otp': otp, 'password': password},
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }
}
