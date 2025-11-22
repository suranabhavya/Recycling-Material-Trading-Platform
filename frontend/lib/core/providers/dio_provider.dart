import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recycling_platform/core/constants/app_constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.connectionTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final storage = ref.watch(secureStorageProvider);
  
  // Add JWT interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: AppConstants.accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token expiration
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - could trigger logout here
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

