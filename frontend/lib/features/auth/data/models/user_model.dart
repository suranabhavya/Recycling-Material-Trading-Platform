class UserModel {
  final String id;
  final String email;
  final String name;
  final String? role;
  final bool isVerified;
  final String? companyId;
  final String? companyApprovalStatus;
  final CompanyModel? company;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    required this.isVerified,
    this.companyId,
    this.companyApprovalStatus,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      companyId: json['companyId'] as String?,
      companyApprovalStatus: json['companyApprovalStatus'] as String?,
      company: json['company'] != null ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>) : null,
    );
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String type;

  CompanyModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String? ?? '',
    );
  }
}

