import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:recycling_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:recycling_platform/features/company/data/models/company_model.dart';
import 'package:recycling_platform/features/company/data/repositories/company_repository.dart';

final companyRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  const storage = FlutterSecureStorage();
  return CompanyRepository(dio, storage);
});

final dioProvider = Provider((ref) => Dio());

class CompanyState {
  final List<CompanyModel> companies;
  final bool isLoading;
  final String? error;
  final CompanyModel? selectedCompany;

  CompanyState({
    this.companies = const [],
    this.isLoading = false,
    this.error,
    this.selectedCompany,
  });

  CompanyState copyWith({
    List<CompanyModel>? companies,
    bool? isLoading,
    String? error,
    CompanyModel? selectedCompany,
  }) {
    return CompanyState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCompany: selectedCompany ?? this.selectedCompany,
    );
  }
}

class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompanyRepository _repository;
  final Ref _ref;

  CompanyNotifier(this._repository, this._ref) : super(CompanyState());

  Future<void> loadCompanies() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final companies = await _repository.getAllCompanies();
      state = state.copyWith(companies: companies, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? 'Failed to load companies',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> createCompany(
    BuildContext context, {
    required String name,
    required String email,
    String? phone,
    String? address,
    required String type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createCompany(
        name: name,
        email: email,
        phone: phone,
        address: address,
        type: type,
      );
      
      // Refresh user data to get updated role and status
      await _ref.read(authProvider.notifier).refreshUser();
      
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company registered successfully!')),
        );
        context.go('/home');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ??
                          'Failed to create company';
      state = state.copyWith(isLoading: false, error: errorMessage);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> joinCompany(BuildContext context, String companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.joinCompany(companyId);
      
      // Refresh user data to get updated company and status
      await _ref.read(authProvider.notifier).refreshUser();
      
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        context.go('/pending-approval');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ??
                          'Failed to join company';
      state = state.copyWith(isLoading: false, error: errorMessage);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }
}

final companyProvider = StateNotifierProvider<CompanyNotifier, CompanyState>((ref) {
  return CompanyNotifier(ref.watch(companyRepositoryProvider), ref);
});

