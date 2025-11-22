import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recycling_platform/core/providers/dio_provider.dart';
import 'package:recycling_platform/features/auth/data/models/user_model.dart';
import 'package:recycling_platform/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool registrationSuccess;
  final bool otpSent;
  final bool passwordReset;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.registrationSuccess = false,
    this.otpSent = false,
    this.passwordReset = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? registrationSuccess,
    bool? otpSent,
    bool? passwordReset,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      registrationSuccess: registrationSuccess ?? this.registrationSuccess,
      otpSent: otpSent ?? this.otpSent,
      passwordReset: passwordReset ?? this.passwordReset,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.register(name: name, email: email, password: password);
      state = AuthState(registrationSuccess: true);
    } on DioError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.verifyOtp(email, otp);
      state = AuthState(user: response.user, isLoading: false);
    } on DioError catch (e) {
      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ??
                          e.message ?? 
                          'Verification failed';
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _repository.resendOtp(email);
    } catch (e) {
      state = state.copyWith(error: 'Failed to resend OTP');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      state = AuthState(user: response.user, isLoading: false);
    } on DioError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Login failed',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email);
      state = AuthState(otpSent: true);
    } on DioError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to send OTP',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(email, otp, password);
      state = AuthState(passwordReset: true);
    } on DioError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Password reset failed',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An error occurred');
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // Silently fail - user data will be refreshed on next login
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
